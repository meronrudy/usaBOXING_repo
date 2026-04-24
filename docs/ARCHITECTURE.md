# Architecture

The architecture is built to make high-trust sport intelligence feel calm: deterministic at the core, flexible at the edges, and clear enough for coaches, researchers, engineers, and procurement teams to inspect.

## Platform Layers

The system moves from stable primitives to sport-specific outcomes:

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

## Kernel Truth

The kernel is `no_std` by default and owns the rules that must remain portable: explicit units, bounded containers, validation primitives, stream semantics, feature records, quality flags, and deterministic errors.

It does not own OS services, file systems, networking, or model training. That boundary is the product advantage: the most important truth can be reused across hosts without inheriting host complexity.

## Runtime and Hosts

The `std` runtime handles the world outside the kernel: ingest, storage, sync, feature execution, model adapters, evaluation, and export. Apple hosts stay intentionally thin, focused on capture, transfer, UI, and local review.

Rust owns deterministic domain logic and C ABI. Swift owns the Apple-native experience.

## Expansion Model

Boxing can be the first polished path without trapping the platform inside boxing. Sport packs, actor packs, fixtures, bundles, and flattened examples should all map back into the same core data model:

`Session -> Actor/Instrument -> Streams -> Events/Segments -> Features -> Predictions -> Reports`
