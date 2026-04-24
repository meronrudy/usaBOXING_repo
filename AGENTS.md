# AGENTS.md

## Purpose
This repo is the foundation for trustworthy sport intelligence: sport-agnostic, actor-agnostic, `no_std`-first Rust with thin Apple hosts. Keep it deterministic, inspectable, and procurement-friendly by design.

## Non-Negotiables
- `no_std` kernel by default; `alloc` optional.
- Zero Python anywhere.
- Deterministic behavior with explicit units, provenance, confidence, and errors.
- Fixed-capacity containers in kernel; avoid unbounded heap.
- No OS services, filesystem, networking, or ML training in kernel.

## Architecture (Layered)
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

## Crate/Folder Graph
See `PROJECT.md` and workspace `Cargo.toml`.

## Data Model
Session -> Actor/Instrument -> Streams -> Events/Segments -> Features -> Predictions -> Reports

## Session Bundle Contract
See `docs/BUNDLE_FORMAT.md`. FFI mechanism is fixed to C ABI with thin Swift wrapper.

## Design Rules
- Explicit units; avoid floats in kernel.
- Provenance on derived artifacts.
- Exhaustive error enums.
- Trait-based instrument HAL.
- Event-sourced, append-friendly, bounded data flow.

## Feature Gates
`std`, `alloc`, `serde`, `ffi`, `onnx`, `opencv`, `boxing`, `swimming`, `rowing`, `equestrian`, `equine`

## Testing Strategy
Unit, property, fixture, and golden tests under crate and runtime `tests/`.

## Security & Robustness
Strict validation, checksums, bounded memory, and a safe FFI boundary. Bad inputs should fail loudly before they can become confident-looking outputs.

## Boundaries
- `no_std`: schemas, units, validation primitives, traits
- `std` runtime: ingest, storage, sync, features, models, eval, export
- Swift hosts: capture, transfer, UI, minimal marshaling
