#![no_std]
pub use sportcore_actors::*;
pub use sportcore_features::*;
pub use sportcore_ids::*;
pub use sportcore_instruments::*;
pub use sportcore_qa::*;
pub use sportcore_semantics::*;
pub use sportcore_streams::*;
pub use sportcore_time::*;
pub use sportcore_units::*;
pub const KERNEL_VERSION: &str = "0.1.0";
pub trait ActorPack { type Landmark; type State; fn actor_kind_code() -> u16; }
pub trait SportAdapter { type Config; type EventKind; type SegmentKind; type Error; fn validate_session(config: &Self::Config, session: &SessionMeta) -> Result<(), Self::Error>; }
pub trait InstrumentStream { type Sample; fn descriptor(&self) -> StreamDescriptor; }
