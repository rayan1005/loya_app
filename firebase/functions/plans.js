// Centralized plan definitions to avoid circular imports.
const PLAN_DEFINITIONS = {
  free: {
    priceId: null,
    limits: {
      programs: 1,
      passes: 20,
      branches: 0,
      broadcastsPerPeriod: 0,
      features: { analytics: false, walletPush: false },
    },
    version: 1,
  },
  basic: {
    priceId: "price_basic_sar_29", // replace with actual Stripe price id
    limits: {
      programs: 1,
      passes: 500,
      branches: 0,
      broadcastsPerPeriod: 10,
      features: { analytics: true, walletPush: true },
    },
    version: 1,
  },
  pro: {
    priceId: "price_pro_sar_79", // replace with actual Stripe price id
    limits: {
      programs: 5,
      passes: 50000,
      branches: 25,
      broadcastsPerPeriod: Number.POSITIVE_INFINITY,
      features: { analytics: true, walletPush: true },
    },
    version: 1,
  },
};

const PRICE_TO_PLAN = Object.entries(PLAN_DEFINITIONS).reduce((acc, [plan, cfg]) => {
  if (cfg.priceId) acc[cfg.priceId] = plan;
  return acc;
}, {});

module.exports = { PLAN_DEFINITIONS, PRICE_TO_PLAN };
