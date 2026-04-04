#![no_std]
use sportcore_actors::BodyRegion;
use sportcore_ids::{ActorId, InstrumentId};
use sportcore_units::Hertz;
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum Modality { Video, Pose, Imu, Force, Pressure, Nirs, HeartRate, Gps, Environment, Annotation }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum MountLocation { ActorRegion(BodyRegion), EquipmentSlot(u16), VenueFixed(u16), Handheld, Unknown }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct InstrumentBinding { pub actor_id: ActorId, pub mount: MountLocation }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct InstrumentDescriptor { pub instrument_id: InstrumentId, pub modality: Modality, pub nominal_rate_hz: Hertz, pub binding: InstrumentBinding, pub calibration_profile: u32 }
