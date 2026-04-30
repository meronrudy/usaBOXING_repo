# Project Overview: 

## 1. Core Concept & Purpose
`usaBOXING` is a deterministic performance platform for instrumented sports. While it starts with boxing, its core is designed to be sport-agnostic and actor-agnostic. The primary goal is to provide a rigorous, trustworthy foundation for athlete assessment by turning raw streams, athlete context, and coaching intent into bounded, explainable outputs. It aims to replace fragile handoffs (devices, video, spreadsheets, subjective decisions) with a clean workflow: capture once, validate hard, preserve provenance, and generate auditable, repeatable outputs.

## 2. Architectural Principles
The architecture is built around a strict separation of concerns, prioritizing determinism and portability:

*   **`no_std` Kernel First:** The core logic (kernel) is `no_std` by default, meaning it doesn't rely on the Rust standard library. It avoids unbounded heap allocation (optional `alloc`), OS services, file systems, networking, or ML training. This ensures the most critical truth can be reused across any host without inheriting host complexity.
*   **Deterministic by Design:** The system enforces explicit units, confidence levels, provenance tracking, and exhaustive error states. It avoids floating-point math in the kernel where possible to maintain determinism.
*   **Thin Apple Host Shells:** The platform uses a C ABI as a stable bridge to thin Swift wrappers. Rust owns the deterministic domain logic, while Swift handles Apple-native experiences like HealthKit integration, WatchConnectivity, UI, and local persistence.
*   **Procurement-Friendly:** The system explicitly avoids Python, hidden services, required cloud dependencies, and in-kernel training, making it easier to audit and procure.

## 3. Data Model & Workflow
The platform follows a coherent, event-sourced data flow:
`Session -> Actor/Instrument -> Streams -> Events/Segments -> Features -> Predictions -> Reports`

## 4. Platform Layers (Crates)
The repository is organized into stable layers, reflected in the `crates/` directory:

1.  **IDs** (`sportcore-ids`): Identifiers for entities.
2.  **Units** (`sportcore-units`): Explicit unit definitions to avoid ambiguity.
3.  **Time** (`sportcore-time`): Timing and synchronization primitives.
4.  **Actors** (`sportcore-actors`): Representations of athletes or subjects.
5.  **Instruments** (`sportcore-instruments`): Trait-based hardware abstraction layer (HAL) for capture devices.
6.  **Streams** (`sportcore-streams`): Raw data streams from instruments.
7.  **Semantics** (`sportcore-semantics`): Meaning and context applied to streams.
8.  **Features** (`sportcore-features`): Derived metrics and characteristics.
9.  **QA** (`sportcore-qa`): Quality assurance, validation, and confidence scoring.
10. **Kernel Truth** (`sportcore-kernel`): The core `no_std` domain logic.
11. **`std` Runtime** (`runtime/`): Handles ingest, storage, sync, feature execution, model adapters, evaluation, and export.
12. **Thin Apple Host Shells** (`hosts/host-macos/SportCoreFFI.swift`, `sportcore-ffi`): The C ABI bridge and Swift integration.

## 5. Key Contracts & Formats
*   **Session Bundle Contract** (`docs/BUNDLE_FORMAT.md`): A portable evidence package for an athlete session. It contains a versioned `manifest.json`, session metadata, actors, instruments, timing anchors, and raw assets (e.g., video). It is designed to be predictable, explicit (with checksums), and strictly validated.
*   **FFI Contract** (`docs/FFI.md`): The C ABI interface uses small, versioned, `#[repr(C)]` structs and exhaustive status codes to ensure a safe and auditable boundary between Rust and Swift.
*   **Evaluation Strategy** (`docs/EVALUATION.md`): Trust is earned through reproducible evaluations. Fixture bundles feed deterministic evaluators to produce golden outputs, ensuring regressions are caught early.

## 6. Expansion Model
The platform is designed for expansion without lock-in. It uses feature gates (`std`, `alloc`, `serde`, `ffi`, `onnx`, `opencv`, `boxing`, `swimming`, `rowing`, `equestrian`, `equine`) to enable specific capabilities or sports. The goal is to allow developers to start with a complete end-to-end example for one sport (like boxing) and easily adapt it for others by swapping out sport packs, actor packs, and fixtures while relying on the same core data model.