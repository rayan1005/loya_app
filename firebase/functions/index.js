const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { app } = require("./app");

if (!admin.apps.length) {
  admin.initializeApp();
}

exports.api = functions.https.onRequest(app);

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const firestore = admin.firestore();
  const userRef = firestore.doc(`user/${user.uid}`);
  // Intentionally keep for future cleanup logic.
  return userRef;
});

exports.onMerchantCreated = functions.firestore
  .document("merchants/{merchantId}")
  .onCreate(async (snap, context) => {
    const merchantId = context.params.merchantId;
    const db = admin.firestore();
    const subscriptionRef = db.collection("subscriptions").doc(merchantId);
    const countersRef = db.collection("merchant_counters").doc(merchantId);
    const batch = db.batch();
    const { PLAN_DEFINITIONS } = require("./plans");
    batch.set(subscriptionRef, {
      plan: "free",
      status: "active",
      periodStart: Date.now(),
      periodEnd: null,
      limits: PLAN_DEFINITIONS.free.limits,
      updatedAt: Date.now(),
    });
    batch.set(countersRef, {
      periodStart: Date.now(),
      activePrograms: 0,
      passes: 0,
      branches: 0,
      broadcastsThisPeriod: 0,
      updatedAt: Date.now(),
    });
    return batch.commit();
  });
