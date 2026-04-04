#![no_std]
use sportcore_ids::{InstrumentId, StreamId};
use sportcore_time::Timestamp;
use sportcore_units::{ConfidenceBp, DegreesMilli, MetersMilli, NewtonMilli, SmO2Bp};
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct StreamDescriptor { pub stream_id: StreamId, pub instrument_id: InstrumentId, pub schema_id: u16 }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct ImuSample { pub ts: Timestamp, pub ax_mg: i32, pub ay_mg: i32, pub az_mg: i32, pub gx_mdps: i32, pub gy_mdps: i32, pub gz_mdps: i32, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct HeartRateSample { pub ts: Timestamp, pub bpm: u16, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct NirsSample { pub ts: Timestamp, pub smo2: SmO2Bp, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct ForceSample { pub ts: Timestamp, pub fx_mn: NewtonMilli, pub fy_mn: NewtonMilli, pub fz_mn: NewtonMilli, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct PoseKeypoint { pub x_mm: MetersMilli, pub y_mm: MetersMilli, pub z_mm: MetersMilli, pub confidence: ConfidenceBp }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct OrientationSample { pub ts: Timestamp, pub yaw_md: DegreesMilli, pub pitch_md: DegreesMilli, pub roll_md: DegreesMilli, pub confidence: ConfidenceBp }
