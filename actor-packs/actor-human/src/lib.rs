#![no_std]
use sportcore_kernel::ActorPack;
pub enum HumanLandmark { Nose, LeftShoulder, RightShoulder, LeftHip, RightHip, LeftWrist, RightWrist, LeftAnkle, RightAnkle }
pub enum HumanState { Standing, Moving, Contacting, Unknown }
pub struct HumanPack;
impl ActorPack for HumanPack { type Landmark = HumanLandmark; type State = HumanState; fn actor_kind_code() -> u16 { 1 } }
