# Project Story

usaBOXING is the working name for a sport-intelligence platform that makes athlete assessment feel simple on the surface and rigorous underneath.

The first developer experience should be approachable: open a single case, understand the athlete, adjust the assessment inputs, and produce a first training recommendation without leaving the file. Under that ergonomic layer, the platform keeps a disciplined architecture so every output can later be unpacked into reusable sportcore pieces.

## Product Shape

- One coherent workflow: athlete profile, instruments, streams, events, segments, features, predictions, and reports.
- One deterministic foundation: Rust kernel truth with explicit units, provenance, confidence, and bounded errors.
- One host strategy: thin Apple shells for capture, transfer, review, and UI, with C ABI as the stable bridge.
- One expansion model: boxing first, but no hard dependency on a single sport, actor, device, or venue.

## Developer Experience North Star

The ideal contributor can start from a complete end-to-end example, rename it for a real athlete, tune the assessment details, and validate the resulting plan. As the SDK matures, that flattened source can be unflattened into the correct sportcore crates, runtime fixtures, bundle contracts, and host-facing interfaces.

## Architecture Map

The repository is organized around stable layers:

1. IDs
2. Units
3. Time
4. Actors
5. Instruments
6. Streams
7. Semantics
8. Features
9. QA
10. Kernel truth
11. `std` runtime
12. Thin Apple host shells

The workspace `Cargo.toml` is the current crate graph. `docs/` captures the platform contracts.
