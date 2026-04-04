#![no_std]
use sportcore_units::{ConfidenceBp, Micros};
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)] pub struct Timestamp(pub Micros);
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct Interval { pub start: Timestamp, pub end: Timestamp }
impl Interval { pub fn is_valid(&self) -> bool { self.start <= self.end } }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum SyncAnchorKind { ManualClap, Bell, RoundStart, RoundEnd, ExternalPulse }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct SyncAnchor { pub ts: Timestamp, pub kind: SyncAnchorKind, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct DriftModel { pub offset_us: i64, pub slope_ppm: i32, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct SessionClock { pub origin: Timestamp }
