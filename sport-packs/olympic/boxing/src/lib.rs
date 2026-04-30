#![no_std]
use sportcore_kernel::{SessionMeta, SportAdapter};
pub enum BoxingEventKind { Jab, Cross, Hook, Uppercut, CombinationStart, CombinationEnd, RoundStart, RoundEnd }
pub enum BoxingSegmentKind { Round, Rest }
pub struct BoxingConfig { pub rounds: u8 }
pub enum BoxingError { InvalidRoundCount }
pub struct BoxingAdapter;
impl SportAdapter for BoxingAdapter { type Config = BoxingConfig; type EventKind = BoxingEventKind; type SegmentKind = BoxingSegmentKind; type Error = BoxingError; fn validate_session(config: &Self::Config, _session: &SessionMeta) -> Result<(), Self::Error> { if config.rounds == 0 { return Err(BoxingError::InvalidRoundCount); } Ok(()) } }
