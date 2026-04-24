# Peakmodoro MVP in `GREENFIELD`

Peakmodoro is the compact proof point for the platform promise: deterministic physiology signals, Apple-native capture, and a recommendation loop that stays understandable from sensor to session.

## Product Summary

- Build Peakmodoro as a focused product root in `GREENFIELD`, preserving the main sports workspace as the broader platform foundation.
- Prove the core architecture in a small, useful loop: Rust computes readiness and session policy; Swift handles HealthKit, WatchConnectivity, workout sessions, desktop review, and UI.
- Target an internal founder/research MVP on paired iPhone and Apple Watch hardware, with a macOS review shell for fast inspection.
- Deliver a recommendation-only closed loop: compute readiness from HealthKit, generate a fixed session recommendation, sync it to watch, run a fixed timer, and inspect readiness payloads on macOS.

## Experience

- On iPhone, the user authorizes HealthKit, refreshes readiness, and sends a clear recommendation to the watch.
- On watch, the user receives the session, starts a live heart-rate workout, and follows a focused timer only when the payload is fresh.
- On macOS, the developer or researcher can review local and sample readiness payloads without pretending the desktop is the capture device.

## Implementation Spine

- `GREENFIELD/crates/peakcore-model`: `no_std` model types, flags, and FFI-safe representations.
- `GREENFIELD/crates/peakcore-estimator`: deterministic readiness and recommendation math.
- `GREENFIELD/crates/peakcore-ffi`: small C ABI that gives Apple hosts a stable bridge.
- `GREENFIELD/apple/Sources/PeakmodoroShared`: payload models, stale gating, and operational persistence.
- `GREENFIELD/apple/Sources/PeakmodoroiPhoneApp`: HealthKit authorization, anchored queries, readiness recompute, and watch sync.
- `GREENFIELD/apple/Sources/PeakmodoroWatchApp`: payload receipt, live HR workout session, focus timer, and stale-session blocking.
- `GREENFIELD/apple/Sources/PeakmodoroMacApp`: desktop review of local and sample readiness payloads.

## Xcode Workflow

- Keep source of truth in this repo: Rust crates, Swift sources, resources, entitlements, `Package.swift`, and `GREENFIELD/apple/project.yml`.
- Expected generated project path is `GREENFIELD/apple/Peakmodoro.xcodeproj`.
- If creating the project manually in Xcode first, create it at `GREENFIELD/apple/Peakmodoro.xcodeproj` and add existing source/resource folders by reference, not as copied files.
- iPhone target references `Sources/PeakmodoroShared`, `Sources/PeakmodoroiPhoneApp`, `Resources/iPhone/Info.plist`, and `Resources/iPhone/PeakmodoroiPhone.entitlements`.
- Watch target references `Sources/PeakmodoroShared`, `Sources/PeakmodoroWatchApp`, `Resources/Watch/Info.plist`, and `Resources/Watch/PeakmodoroWatch.entitlements`.
- Mac target references `Sources/PeakmodoroShared`, `Sources/PeakmodoroMacApp`, and `Resources/Mac/Info.plist`.

## Public Interfaces

- `pm_version_major() -> int32`
- `pm_version_minor() -> int32`
- `pm_compute_readiness(const PmEstimatorInput*, PmReadinessOutput*) -> int32`
- `pm_recommend_session(const PmReadinessOutput*, PmRecommendation*) -> int32`
- FFI structs are frozen for the MVP in `GREENFIELD/crates/peakcore-ffi/include/peakcore.h`.

## Verification

- `cargo test` in `GREENFIELD`
- `swift run PeakmodoroValidation` in `GREENFIELD/apple`
- `xcrun swiftc -typecheck -parse-as-library -target arm64-apple-macosx15.0 Sources/PeakmodoroShared/*.swift Sources/PeakmodoroMacApp/*.swift` in `GREENFIELD/apple`
- Full iPhone/watch/macOS app compilation remains pending a generated or manually created Xcode project plus signing/device configuration.

## Guardrails

- `GREENFIELD` remains a separate product root and is not added to the existing top-level Cargo workspace.
- No cloud, analytics backend, paywall, long-term history, or online learning are part of the MVP.
- Shared Swift verification stays CLI-based until full Xcode test infrastructure is available.
- The macOS shell is a desktop review layer; it does not replace iPhone HealthKit ingestion or watch workout capture.
