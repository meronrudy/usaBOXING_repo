# Peakmodoro

Peakmodoro is the internal MVP that proves the platform can turn physiology signals into a simple, trustworthy action: what session should I do right now?

It is intentionally small. The point is not to build a giant wellness app; the point is to demonstrate the loop that matters: Apple-native capture, deterministic Rust readiness, clear recommendation, watch delivery, and local review.

## What It Includes

- `crates/peakcore-model`: `no_std` FFI-safe types and flags.
- `crates/peakcore-estimator`: deterministic readiness and policy math.
- `crates/peakcore-ffi`: C ABI for Apple host apps.
- `apple/`: Swift package for shared logic plus iPhone, watch, and macOS app sources and Xcode project spec.

## User Experience

- iPhone gathers HealthKit context and computes readiness.
- Watch receives the recommendation and runs the workout timer with live heart-rate capture.
- macOS gives developers and researchers a fast review surface for local and sample payloads.

## Constraints

- Rust owns deterministic domain logic and fixed ABI.
- Swift owns HealthKit, WatchConnectivity, workout sessions, desktop review, and UI.
- No cloud, no analytics backend, no persisted history, no online learning.
