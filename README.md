# usaBOXING

The deterministic performance platform for instrumented sport.

usaBOXING starts with boxing, but the core is built to travel: sport-agnostic, actor-agnostic, `no_std`-first Rust with thin Apple host shells. It turns raw streams, athlete context, and coaching intent into bounded, explainable outputs that can survive real-world capture, review, procurement, and repeat use.

## Why It Exists

Modern athlete assessment is full of fragile handoffs: devices, video, spreadsheets, local notes, subjective decisions, and disconnected workout plans. This repo is the foundation for a cleaner workflow: capture once, validate hard, preserve provenance, and generate outputs that can be audited, repeated, and adapted.

## What Makes It Different

- Deterministic by design: explicit units, confidence, provenance, and error states.
- Built for constrained environments: `no_std` kernel first, optional `alloc`, fixed-capacity data flow.
- Procurement-friendly boundaries: no Python, no hidden services, no required cloud, no training in the kernel.
- Sport expansion without lock-in: IDs, units, time, actors, instruments, streams, semantics, features, QA, and runtime stay layered.
- Apple-native capture path: Rust owns truth and ABI; Swift stays thin around HealthKit, WatchConnectivity, workout capture, and UI.

## Platform Promise

Start with one athlete, one assessment, and one first workout. Keep the path rigorous enough to become a full SDK: session bundles, validated streams, derived features, predictions, reports, and export surfaces all map back to deterministic source data.

## Non-Negotiables

- Zero Python anywhere.
- `no_std` kernel by default.
- Deterministic behavior across validation, feature extraction, and recommendations.
- C ABI plus thin Swift wrapper for host integration.
- Bounded memory and explicit failure modes at the kernel boundary.
