#![no_std]
use sportcore_kernel::ActorPack;
pub enum EquineLandmark { Poll, Withers, ShoulderLeft, ShoulderRight, HipLeft, HipRight, HoofFrontLeft, HoofFrontRight, HoofRearLeft, HoofRearRight }
pub enum EquineState { Halt, Walk, Trot, Canter, Gallop, Jumping, Unknown }
pub struct EquinePack;
impl ActorPack for EquinePack { type Landmark = EquineLandmark; type State = EquineState; fn actor_kind_code() -> u16 { 2 } }
