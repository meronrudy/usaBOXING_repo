#![no_std]
use sportcore_ids::{ActorId, FeatureId};
use sportcore_time::Interval;
use sportcore_units::ConfidenceBp;
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub enum FeatureFamily { Variability, Stability, Asymmetry, Pace, Decay, Coupling, Lag, Density }
#[derive(Clone, Copy, Debug, PartialEq, Eq)] pub struct FeatureRecord { pub feature_id: FeatureId, pub family: FeatureFamily, pub actor_id: ActorId, pub interval: Interval, pub value_q16: i32, pub confidence: ConfidenceBp, pub provenance_code: u32 }
pub fn bounded_mean_i32(samples: &[i32]) -> Option<i32> { if samples.is_empty() { return None; } let sum: i64 = samples.iter().map(|x| *x as i64).sum(); Some((sum / samples.len() as i64) as i32) }
