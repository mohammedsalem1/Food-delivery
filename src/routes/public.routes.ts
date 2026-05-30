import express from "express";

const publicRouter = express.Router();

publicRouter.get("/health", (_req, res) => {
  res.json({ ok: true, service: "food-delivery-api" });
});

/** Public config for the customer storefront (no auth). */
publicRouter.get("/config", (_req, res) => {
  res.json({
    success: true,
    data: {
      stripePublishableKey: process.env.STRIPE_PUBLISHABLE_KEY || "",
    },
  });
});

export { publicRouter };
