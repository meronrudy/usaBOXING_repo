#![no_std]

use sportcore_kernel::{SportAdapter, SessionMeta};

pub struct Config;

pub enum Error {
    InvalidSession,
}

pub enum EventKind {}
pub enum SegmentKind {}

pub struct Adapter;

impl SportAdapter for Adapter {
    type Config = Config;
    type Error = Error;
    type EventKind = EventKind;
    type SegmentKind = SegmentKind;

    fn validate_session(_config: &Self::Config, _session: &SessionMeta) -> Result<(), Self::Error> {
        Ok(())
    }
}
