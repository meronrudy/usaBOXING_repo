# FFI

The FFI layer is the handshake between deterministic Rust truth and polished Apple-native experiences.

## Chosen Approach

Use a C ABI plus a thin Swift wrapper. Exported types stay small, versioned, and `#[repr(C)]` so the bridge is easy to audit and hard to surprise.

## Why This Matters

- Rust can own the repeatable math, validation, and recommendation logic.
- Swift can own HealthKit, WatchConnectivity, workout sessions, UI, and local persistence.
- Procurement and QA can inspect a narrow boundary instead of chasing behavior across two ecosystems.

## Interface Principles

- Keep structs flat and explicit.
- Version public functions and payload layouts.
- Return exhaustive status codes instead of panicking across the boundary.
- Treat the ABI as a product contract, not an implementation detail.
