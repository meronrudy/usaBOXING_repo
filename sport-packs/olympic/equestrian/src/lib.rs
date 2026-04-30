#![no_std]
use sportcore_kernel::{SessionMeta, SportAdapter};
pub enum EquestrianEventKind { Walk, Trot, Canter, LeadChange, JumpTakeoff, JumpLanding, Refusal }
pub enum EquestrianSegmentKind { Warmup, Flatwork, CourseRun }
pub struct EquestrianConfig { pub obstacle_count: u8 }
pub enum EquestrianError { InvalidObstacleCount }
pub struct EquestrianAdapter;
impl SportAdapter for EquestrianAdapter { type Config = EquestrianConfig; type EventKind = EquestrianEventKind; type SegmentKind = EquestrianSegmentKind; type Error = EquestrianError; fn validate_session(_config: &Self::Config, _session: &SessionMeta) -> Result<(), Self::Error> { Ok(()) } }
