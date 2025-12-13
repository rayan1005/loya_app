const express = require("express");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const { PLAN_DEFINITIONS, PRICE_TO_PLAN } = require("./plans");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const app = express();

// Webhook must be registered with raw parser before any JSON middleware.
app.post("/stripe/webhook", express.raw({ type: "application/json" }), async (req, res) => {
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      req.headers["stripe-signature"],
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    functions.logger.error("Webhook signature verification failed", err);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    const processed = await handleStripeEvent(event);
    if (!processed) {
      return res.status(200).send("ignored");
    }
    return res.status(200).send("ok");
  } catch (err) {
    functions.logger.error("Webhook handler error", err);
    return res.status(500).send("Internal error");
  }
});

// All other routes use JSON body parsing.
app.use(express.json());

// Simple Firebase Auth check using ID token; resolves merchant by ownerUid.
async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";
    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "unauthenticated" });
    }
    const idToken = authHeader.replace("Bearer ", "");
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = decoded;
    const merchantSnap = await db
      .collection("merchants")
      .where("ownerUid", "==", decoded.uid)
      .limit(1)
      .get();
    if (merchantSnap.empty) {
      return res.status(403).json({ error: "merchant_not_found" });
    }
    const merchantDoc = merchantSnap.docs[0];
    req.merchantId = merchantDoc.id;
    req.merchant = merchantDoc.data();
    return next();
  } catch (err) {
    functions.logger.error("authMiddleware failed", err);
    return res.status(401).json({ error: "unauthenticated" });
  }
}

// Checkout session (website only). Apple Pay Web is enabled at the Stripe account level; use payment_method_types ["card"].
app.post("/subscriptions/checkout", authMiddleware, async (req, res) => {
  const { plan } = req.body || {};
  const planDef = PLAN_DEFINITIONS[plan];
  if (!planDef || !planDef.priceId) {
    return res.status(400).json({ error: "invalid_plan" });
  }

  const customerId = await getOrCreateStripeCustomer(req.merchantId, req.user.email);
  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    customer: customerId,
    client_reference_id: req.merchantId,
    subscription_data: {
      metadata: { merchantId: req.merchantId },
    },
    line_items: [{ price: planDef.priceId, quantity: 1 }],
    success_url: `${process.env.WEB_URL}/billing/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.WEB_URL}/billing/cancel`,
    payment_method_types: ["card"],
    allow_promotion_codes: true,
  });

  return res.json({ url: session.url });
});

app.post("/subscriptions/portal", authMiddleware, async (req, res) => {
  const customerId = await getOrCreateStripeCustomer(req.merchantId, req.user.email);
  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: `${process.env.WEB_URL}/billing`,
  });
  return res.json({ url: session.url });
});

// Subscription-aware middleware and limit enforcement using counters collection.
async function withSubscription(req, res, next) {
  const snap = await db.collection("subscriptions").doc(req.merchantId).get();
  const data = snap.exists ? snap.data() : null;
  req.subscription =
    data || { plan: "free", status: "active", limits: PLAN_DEFINITIONS.free.limits };

  if (!["active", "trialing", "past_due", "canceled"].includes(req.subscription.status)) {
    return res.status(402).json({
      code: "subscription_inactive",
      message: "Subscription inactive. Please restart to continue.",
      plan: req.subscription.plan,
      action: "upgrade",
    });
  }
  if (req.subscription.status === "canceled") {
    return res
      .status(402)
      .json({
        code: "subscription_canceled",
        message: "Subscription canceled. Please restart to continue.",
        plan: req.subscription.plan,
        action: "upgrade",
      });
  }
  return next();
}

async function getCounters(merchantId, subscription) {
  const snap = await db.collection("merchant_counters").doc(merchantId).get();
  const data = snap.exists ? snap.data() : {};
  const periodStart = subscription?.periodStart || 0;
  const aligned = data.periodStart === periodStart;
  const broadcasts = aligned ? data.broadcastsThisPeriod || 0 : 0;
  return {
    programs: aligned ? data.activePrograms || 0 : 0,
    passes: aligned ? data.passes || 0 : 0,
    branches: aligned ? data.branches || 0 : 0,
    broadcasts,
    broadcastsPerPeriod: broadcasts,
  };
}

function enforceLimit(kind) {
  return async (req, res, next) => {
    const limits = req.subscription.limits || {};
    const cap = limits[kind];
    if (cap === undefined || cap === Number.POSITIVE_INFINITY) {
      return next();
    }
    if (req.subscription.status === "past_due") {
      return res.status(402).json({
        code: "subscription_past_due",
        message: "Payment failed. Please update billing to continue.",
        plan: req.subscription.plan,
        action: "resume_billing",
      });
    }
    const counters = await getCounters(req.merchantId, req.subscription);
    if ((counters[kind] || 0) >= cap) {
      return res.status(403).json({
        code: `${kind}_limit_reached`,
        message: "Limit reached for your current plan.",
        plan: req.subscription.plan,
        action: "upgrade",
      });
    }
    return next();
  };
}

function requireFeature(featureKey) {
  return (req, res, next) => {
    const enabled = req.subscription.limits?.features?.[featureKey];
    if (!enabled) {
      return res.status(403).json({
        code: "feature_not_available",
        message: "Feature not available on this plan.",
        plan: req.subscription.plan,
        action: "upgrade",
      });
    }
    return next();
  };
}

function bumpCounter(kind, delta = 1) {
  return async (req, res, next) => {
    try {
      await bumpCountersInternal(req.merchantId, req.subscription, { [kind]: delta });
      return next();
    } catch (err) {
      functions.logger.error("Failed to bump counter", { kind, err });
      return res.status(500).json({ error: "counter_update_failed" });
    }
  };
}

async function bumpCountersInternal(merchantId, subscription, increments) {
  const periodStart = subscription?.periodStart || 0;
  const ref = db.collection("merchant_counters").doc(merchantId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const existing = snap.exists ? snap.data() : {};
    const samePeriod = existing.periodStart === periodStart;
    if (!samePeriod) {
      tx.set(ref, {
        periodStart,
        activePrograms: increments.programs || 0,
        passes: increments.passes || 0,
        branches: increments.branches || 0,
        broadcastsThisPeriod: increments.broadcasts || 0,
        updatedAt: Date.now(),
      });
      return;
    }
    tx.set(
      ref,
      {
        activePrograms: admin.firestore.FieldValue.increment(increments.programs || 0),
        passes: admin.firestore.FieldValue.increment(increments.passes || 0),
        branches: admin.firestore.FieldValue.increment(increments.branches || 0),
        broadcastsThisPeriod: admin.firestore.FieldValue.increment(
          increments.broadcasts || 0
        ),
        updatedAt: Date.now(),
      },
      { merge: true }
    );
  });
}

// Billing summary endpoint for web/mobile dashboards.
app.get("/billing/summary", authMiddleware, withSubscription, async (req, res) => {
  try {
    const counters = await getCounters(req.merchantId, req.subscription);
    return res.json({
      merchantId: req.merchantId,
      plan: req.subscription.plan,
      status: req.subscription.status,
      limits: req.subscription.limits,
      usage: {
        programs: counters.programs,
        passes: counters.passes,
        branches: counters.branches,
        broadcastsThisPeriod: counters.broadcasts,
      },
      nextBillingDate: req.subscription.periodEnd || null,
    });
  } catch (err) {
    functions.logger.error("billing summary failed", err);
    return res.status(500).json({ error: "billing_summary_failed" });
  }
});

// Helpers
async function getOrCreateStripeCustomer(merchantId, email) {
  const subRef = db.collection("subscriptions").doc(merchantId);
  const subSnap = await subRef.get();
  const existing = subSnap.exists ? subSnap.data().stripeCustomerId : null;
  if (existing) return existing;
  const customer = await stripe.customers.create({ email, metadata: { merchantId } });
  await subRef.set({ stripeCustomerId: customer.id, updatedAt: Date.now() }, { merge: true });
  return customer.id;
}

async function handleStripeEvent(event) {
  const type = event.type;
  const object = event.data.object;

  // Idempotency: skip if already processed.
  const already = await db
    .collection("billing_events")
    .where("stripeEventId", "==", event.id)
    .limit(1)
    .get();
  if (!already.empty) {
    return false;
  }

  const recordBillingEvent = async (merchantId, payload) => {
    await db.collection("billing_events").add({
      merchantId,
      stripeEventId: event.id,
      type,
      data: payload,
      createdAt: Date.now(),
    });
  };

  if (type === "checkout.session.completed" && object.subscription) {
    const session = object;
    const subscription = await stripe.subscriptions.retrieve(session.subscription);
    const merchantId =
      session.client_reference_id ||
      session.metadata?.merchantId ||
      subscription.metadata?.merchantId;
    if (merchantId) {
      await upsertSubscriptionFromStripe(subscription, merchantId);
      await recordBillingEvent(merchantId, { subscriptionId: subscription.id });
    }
    return true;
  }

  if (
    type === "customer.subscription.created" ||
    type === "customer.subscription.updated" ||
    type === "customer.subscription.deleted"
  ) {
    const subscription = object;
    const merchantId = subscription.metadata?.merchantId;
    if (merchantId) {
      await upsertSubscriptionFromStripe(subscription, merchantId);
      await recordBillingEvent(merchantId, { subscriptionId: subscription.id });
    }
  }

  if (type === "invoice.payment_failed" || type === "invoice.paid") {
    const invoice = object;
    const subscriptionId = invoice.subscription;
    if (!subscriptionId) return true;
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    const merchantId = subscription.metadata?.merchantId;
    if (merchantId) {
      await upsertSubscriptionFromStripe(subscription, merchantId, {
        forceStatus:
          type === "invoice.payment_failed" ? "past_due" : subscription.status,
      });
      await recordBillingEvent(merchantId, { invoiceId: invoice.id });
    }
  }

  return true;
}

async function upsertSubscriptionFromStripe(subscription, merchantId, options = {}) {
  const priceId = subscription.items?.data?.[0]?.price?.id;
  const planKey = PRICE_TO_PLAN[priceId] || "free";
  const planDef = PLAN_DEFINITIONS[planKey] || PLAN_DEFINITIONS.free;
  const statusMap = {
    active: "active",
    trialing: "trialing",
    past_due: "past_due",
    incomplete: "incomplete",
    canceled: "canceled",
    unpaid: "past_due",
  };

  const payload = {
    plan: planKey,
    status: statusMap[options.forceStatus || subscription.status] || "past_due",
    periodStart: subscription.current_period_start * 1000,
    periodEnd: subscription.current_period_end * 1000,
    limits: planDef.limits, // only caps/features, no Stripe price ids
    stripeSubscriptionId: subscription.id,
    stripeCustomerId: subscription.customer,
    stripePriceId: priceId,
    planVersion: planDef.version || 1,
    updatedAt: Date.now(),
  };

  const subRef = db.collection("subscriptions").doc(merchantId);
  await subRef.set(payload, { merge: true });
  await db
    .collection("merchants")
    .doc(merchantId)
    .set(
      {
        subscriptionPlan: payload.plan,
        subscriptionStatus: payload.status,
        subscriptionLimits: payload.limits,
        subscriptionRef: subRef,
      },
      { merge: true }
    );
  await db.collection("billing_events").add({
    merchantId,
    stripeEventId: subscription.latest_invoice || null,
    type: "customer.subscription.sync",
    data: payload,
    createdAt: Date.now(),
  });
}

module.exports = {
  app,
  withSubscription,
  enforceLimit,
  requireFeature,
  bumpCounter,
  PLAN_DEFINITIONS,
};
