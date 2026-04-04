#![no_std]

use peakcore_model::{
    AVAILABILITY_HRV, AVAILABILITY_RESPIRATORY_RATE, AVAILABILITY_RESTING_HR, AVAILABILITY_SLEEP,
    PmEstimatorInput, PmReadinessOutput, PmRecommendation, ReadinessBand, STALE_REASON_NONE,
};

pub fn compute_readiness(input: &PmEstimatorInput) -> PmReadinessOutput {
    let sleep_score = score_sleep(input);
    let hrv_score = score_hrv(input);
    let resting_hr_score = score_resting_hr(input);
    let resp_score = score_resp(input);
    let hrv_stability = score_hrv_stability(input);
    let resp_stability = score_resp_stability(input);

    let readiness = clamp_u8(
        (40 * sleep_score + 30 * hrv_score + 20 * resting_hr_score + 10 * resp_score) / 100,
    );
    let fatigue = clamp_u8(100 - ((60 * sleep_score + 40 * resting_hr_score) / 100));
    let volatility = clamp_u8(100 - ((70 * hrv_stability + 30 * resp_stability) / 100));
    let confidence = compute_confidence(input);
    let band = band_for(readiness);

    PmReadinessOutput {
        readiness,
        fatigue,
        volatility,
        confidence,
        band: band as u8,
    }
}

pub fn recommend_session(output: &PmReadinessOutput) -> PmRecommendation {
    let (focus_minutes, break_minutes) = match output.band {
        x if x == ReadinessBand::Green as u8 => (40, 7),
        x if x == ReadinessBand::Yellow as u8 => (25, 10),
        _ => (12, 15),
    };

    PmRecommendation {
        focus_minutes,
        break_minutes,
        stale_reason_code: STALE_REASON_NONE,
    }
}

pub fn band_for(readiness: u8) -> ReadinessBand {
    match readiness {
        70..=u8::MAX => ReadinessBand::Green,
        45..=69 => ReadinessBand::Yellow,
        _ => ReadinessBand::Red,
    }
}

fn score_sleep(input: &PmEstimatorInput) -> i32 {
    let duration_score = linear_score(input.sleep_duration_minutes as i32, 360, 480);
    let wakefulness_score = inverse_linear_score(input.sleep_recency_minutes as i32, 720, 1080);
    ((70 * duration_score) + (30 * wakefulness_score)) / 100
}

fn score_hrv(input: &PmEstimatorInput) -> i32 {
    if !input.has_flag(AVAILABILITY_HRV) || input.hrv_sdnn_latest_ms == 0 || input.hrv_sdnn_median_7d_ms == 0 {
        return 50;
    }

    relative_delta_score(
        input.hrv_sdnn_latest_ms as i32,
        input.hrv_sdnn_median_7d_ms as i32,
        true,
        50,
    )
}

fn score_resting_hr(input: &PmEstimatorInput) -> i32 {
    if !input.has_flag(AVAILABILITY_RESTING_HR)
        || input.resting_hr_latest_bpm == 0
        || input.resting_hr_median_7d_bpm == 0
    {
        return 50;
    }

    relative_delta_score(
        input.resting_hr_latest_bpm as i32,
        input.resting_hr_median_7d_bpm as i32,
        false,
        25,
    )
}

fn score_resp(input: &PmEstimatorInput) -> i32 {
    if !input.has_flag(AVAILABILITY_RESPIRATORY_RATE)
        || input.respiratory_rate_latest_tenths == 0
        || input.respiratory_rate_median_7d_tenths == 0
    {
        return 50;
    }

    stability_score(
        input.respiratory_rate_latest_tenths as i32,
        input.respiratory_rate_median_7d_tenths as i32,
        20,
    )
}

fn score_hrv_stability(input: &PmEstimatorInput) -> i32 {
    if !input.has_flag(AVAILABILITY_HRV) || input.hrv_sdnn_latest_ms == 0 || input.hrv_sdnn_median_7d_ms == 0 {
        return 40;
    }

    stability_score(input.hrv_sdnn_latest_ms as i32, input.hrv_sdnn_median_7d_ms as i32, 35)
}

fn score_resp_stability(input: &PmEstimatorInput) -> i32 {
    if !input.has_flag(AVAILABILITY_RESPIRATORY_RATE)
        || input.respiratory_rate_latest_tenths == 0
        || input.respiratory_rate_median_7d_tenths == 0
    {
        return 40;
    }

    stability_score(
        input.respiratory_rate_latest_tenths as i32,
        input.respiratory_rate_median_7d_tenths as i32,
        20,
    )
}

fn compute_confidence(input: &PmEstimatorInput) -> u8 {
    let mut confidence = 100;

    confidence -= signal_penalty(input.has_flag(AVAILABILITY_HRV), input.hrv_age_hours);
    confidence -= signal_penalty(input.has_flag(AVAILABILITY_RESTING_HR), input.resting_hr_age_hours);
    confidence -= signal_penalty(
        input.has_flag(AVAILABILITY_RESPIRATORY_RATE),
        input.respiratory_age_hours,
    );
    confidence -= signal_penalty(input.has_flag(AVAILABILITY_SLEEP), input.sleep_age_hours);

    clamp_u8(confidence)
}

fn signal_penalty(is_present: bool, age_hours: u16) -> i32 {
    if !is_present {
        return 25;
    }
    if age_hours > 48 {
        return 20;
    }
    if age_hours > 24 {
        return 10;
    }
    0
}

fn relative_delta_score(latest: i32, median: i32, higher_is_better: bool, tolerance_percent: i32) -> i32 {
    let tolerance = ((median * tolerance_percent) / 100).max(1);
    let signed_delta = if higher_is_better {
        latest - median
    } else {
        median - latest
    };
    clamp_i32(50 + ((signed_delta * 50) / tolerance))
}

fn stability_score(latest: i32, median: i32, tolerance_percent: i32) -> i32 {
    let tolerance = ((median * tolerance_percent) / 100).max(1);
    let delta = (latest - median).abs();
    clamp_i32(100 - ((delta * 100) / tolerance))
}

fn linear_score(value: i32, floor: i32, target: i32) -> i32 {
    if value <= floor {
        return 0;
    }
    if value >= target {
        return 100;
    }
    ((value - floor) * 100) / (target - floor)
}

fn inverse_linear_score(value: i32, floor: i32, ceiling: i32) -> i32 {
    if value <= floor {
        return 100;
    }
    if value >= ceiling {
        return 0;
    }
    100 - (((value - floor) * 100) / (ceiling - floor))
}

fn clamp_i32(value: i32) -> i32 {
    value.clamp(0, 100)
}

fn clamp_u8(value: i32) -> u8 {
    clamp_i32(value) as u8
}
