# Peakmodoro MVP in `GREENFIELD`

## Summary
- Build Peakmodoro as a new product root in `GREENFIELD`, not by refactoring the existing sports workspace.
- Keep the repo architecture discipline: Rust owns deterministic domain logic and C ABI; Swift owns HealthKit, WatchConnectivity, workout sessions, desktop review, and UI.
- Release target is an internal founder/research MVP on paired iPhone + Apple Watch hardware, with a thin macOS review shell for development and local inspection.
- MVP behavior is recommendation-only closed loop: compute readiness from HealthKit, generate a fixed session recommendation, sync it to watch, run a fixed timer, and optionally inspect readiness payloads on macOS.

## Implementation Changes
- Separate Rust workspace under `GREENFIELD` with `peakcore-model`, `peakcore-estimator`, and `peakcore-ffi`.
- Shared Apple logic under `GREENFIELD/apple/Sources/PeakmodoroShared` for payload models, stale gating, and operational persistence.
- iPhone shell under `GREENFIELD/apple/Sources/PeakmodoroiPhoneApp` for HealthKit authorization, anchored queries, readiness recompute, and watch sync.
- Watch shell under `GREENFIELD/apple/Sources/PeakmodoroWatchApp` for payload receipt, live HR workout session, focus timer, and stale-session blocking.
- macOS shell under `GREENFIELD/apple/Sources/PeakmodoroMacApp` for desktop review of local and sample readiness payloads.
- Xcode project specification under `GREENFIELD/apple/project.yml` with iPhone, watch, and macOS app targets plus HealthKit entitlements where needed.

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
- FFI structs frozen for MVP in `GREENFIELD/crates/peakcore-ffi/include/peakcore.h`.

## Verification
- `cargo test` in `GREENFIELD`
- `swift run PeakmodoroValidation` in `GREENFIELD/apple`
- `xcrun swiftc -typecheck -parse-as-library -target arm64-apple-macosx15.0 Sources/PeakmodoroShared/*.swift Sources/PeakmodoroMacApp/*.swift` in `GREENFIELD/apple`
- Full iPhone/watch/macOS app compilation remains pending a generated or manually created Xcode project plus signing/device configuration.

## Assumptions
- `GREENFIELD` remains a separate product root and is not added to the existing top-level Cargo workspace.
- No cloud, analytics backend, paywall, long-term history, or online learning are part of MVP.
- Shared Swift verification is CLI-based because the current environment lacks full Xcode test frameworks.
- The macOS shell is a desktop review layer; it does not replace iPhone HealthKit ingestion or watch workout capture.
