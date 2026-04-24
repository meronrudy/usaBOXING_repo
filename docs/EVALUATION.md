# Evaluation

Evaluation is how the platform earns trust. Every score, recommendation, and report should be reproducible enough for engineering review and legible enough for coaching decisions.

## What We Measure

- Data quality: missing streams, confidence levels, timing drift, calibration state, and truncation.
- Feature stability: deterministic outputs for the same bounded inputs.
- Model behavior: fixed splits, explicit ablations, and versioned prediction surfaces.
- Product usefulness: whether an assessment produces a clear next action, such as the first workout recommendation for an athlete.

## Golden Path

Fixture bundles feed deterministic evaluators. Evaluators produce summaries and goldens. Goldens make regressions obvious before they reach a host app or a coach-facing workflow.

## Rules

- No hidden randomness in expected outputs.
- No silent data repair.
- Units, provenance, confidence, and errors travel with derived artifacts.
- Any model-backed result must remain explainable at the interface where it is consumed.
