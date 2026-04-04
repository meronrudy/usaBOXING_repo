# Peakmodoro

Internal MVP scaffold for a physiology-adaptive focus timer.

Structure:
- `crates/peakcore-model`: `no_std` FFI-safe types and flags
- `crates/peakcore-estimator`: `no_std` deterministic readiness and policy math
- `crates/peakcore-ffi`: C ABI for Apple host apps
- `apple/`: Swift package for shared logic plus iPhone, watch, and macOS app sources and Xcode project spec

Constraints:
- Rust owns deterministic domain logic and fixed ABI.
- Swift owns HealthKit, WatchConnectivity, workout sessions, desktop review, and UI.
- No cloud, no analytics backend, no persisted history, no online learning.
