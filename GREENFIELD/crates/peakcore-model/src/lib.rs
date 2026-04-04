#![no_std]

pub const PM_VERSION_MAJOR: i32 = 0;
pub const PM_VERSION_MINOR: i32 = 1;

pub const AVAILABILITY_HEART_RATE: u32 = 1 << 0;
pub const AVAILABILITY_HRV: u32 = 1 << 1;
pub const AVAILABILITY_RESTING_HR: u32 = 1 << 2;
pub const AVAILABILITY_RESPIRATORY_RATE: u32 = 1 << 3;
pub const AVAILABILITY_SLEEP: u32 = 1 << 4;
pub const AVAILABILITY_WATCH_HEART_RATE: u32 = 1 << 5;

pub const STALE_REASON_NONE: u8 = 0;
pub const STALE_REASON_MISSING_REQUIRED_SIGNAL: u8 = 1;
pub const STALE_REASON_STALE_SNAPSHOT: u8 = 2;
pub const STALE_REASON_PERMISSION_STATE_CHANGED: u8 = 3;

#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub enum ReadinessBand {
    #[default]
    Red = 0,
    Yellow = 1,
    Green = 2,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct PmEstimatorInput {
    pub sleep_duration_minutes: u16,
    pub sleep_recency_minutes: u16,
    pub hrv_sdnn_latest_ms: u16,
    pub hrv_sdnn_median_7d_ms: u16,
    pub resting_hr_latest_bpm: u16,
    pub resting_hr_median_7d_bpm: u16,
    pub respiratory_rate_latest_tenths: u16,
    pub respiratory_rate_median_7d_tenths: u16,
    pub live_hr_delta_bpm: i16,
    pub hrv_age_hours: u16,
    pub resting_hr_age_hours: u16,
    pub respiratory_age_hours: u16,
    pub sleep_age_hours: u16,
    pub availability_flags: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct PmReadinessOutput {
    pub readiness: u8,
    pub fatigue: u8,
    pub volatility: u8,
    pub confidence: u8,
    pub band: u8,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct PmRecommendation {
    pub focus_minutes: u16,
    pub break_minutes: u16,
    pub stale_reason_code: u8,
}

impl PmEstimatorInput {
    pub const fn has_flag(&self, flag: u32) -> bool {
        (self.availability_flags & flag) == flag
    }
}
