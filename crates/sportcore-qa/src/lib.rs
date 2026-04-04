#![no_std]
use bitflags::bitflags;
bitflags! { #[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct QualityFlags: u32 { const TIME_NON_MONOTONIC = 1 << 0; const LOW_CONFIDENCE = 1 << 1; const MISSING_DATA = 1 << 2; const RATE_MISMATCH = 1 << 3; const DRIFT_OUT_OF_BOUNDS = 1 << 4; const CALIBRATION_UNKNOWN = 1 << 5; const STREAM_TRUNCATED = 1 << 6; const OCCLUDED = 1 << 7; } }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum ValidationError { InvalidInterval, NonMonotonicTime, UnsupportedSchema, ActorBindingMismatch, StreamRateMismatch, CapacityExceeded }
