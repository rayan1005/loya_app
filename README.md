# LoyaApp

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## Billing / Subscriptions (Backend)

Env vars (Cloud Functions):
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `WEB_URL` (used for Checkout/Portal return URLs)

Stripe setup:
- Enable Apple Pay Web in Stripe Dashboard and verify your domain.
- Configure price IDs for `basic` and `pro` plans in `firebase/functions/plans.js`.
- Point Stripe webhooks to the deployed `stripe/webhook` endpoint with the signing secret above.

Adding a new plan safely:
- Add a new entry in `firebase/functions/plans.js` with `priceId`, `limits`, and `version`.
- No schema change required; webhook + middleware pick it up automatically.
