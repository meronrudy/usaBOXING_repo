use peakcore_estimator::{band_for, compute_readiness, recommend_session};
use peakcore_model::{
    AVAILABILITY_HEART_RATE, AVAILABILITY_HRV, AVAILABILITY_RESPIRATORY_RATE,
    AVAILABILITY_RESTING_HR, AVAILABILITY_SLEEP, PmEstimatorInput, PmReadinessOutput,
    ReadinessBand,
};

fn happy_input() -> PmEstimatorInput {
    PmEstimatorInput {
        sleep_duration_minutes: 480,
        sleep_recency_minutes: 600,
        hrv_sdnn_latest_ms: 60,
        hrv_sdnn_median_7d_ms: 55,
        resting_hr_latest_bpm: 54,
        resting_hr_median_7d_bpm: 56,
        respiratory_rate_latest_tenths: 145,
        respiratory_rate_median_7d_tenths: 150,
        live_hr_delta_bpm: 0,
        hrv_age_hours: 8,
        resting_hr_age_hours: 8,
        respiratory_age_hours: 8,
        sleep_age_hours: 6,
        availability_flags: AVAILABILITY_HEART_RATE
            | AVAILABILITY_HRV
            | AVAILABILITY_RESTING_HR
            | AVAILABILITY_RESPIRATORY_RATE
            | AVAILABILITY_SLEEP,
    }
}

#[test]
fn thresholds_map_to_expected_bands() {
    assert_eq!(band_for(70), ReadinessBand::Green);
    assert_eq!(band_for(45), ReadinessBand::Yellow);
    assert_eq!(band_for(44), ReadinessBand::Red);
}

#[test]
fn recommendation_policy_is_fixed_by_band() {
    let green = recommend_session(&compute_readiness(&happy_input()));
    assert_eq!(green.focus_minutes, 40);
    assert_eq!(green.break_minutes, 7);

    let yellow = recommend_session(&PmReadinessOutput {
        readiness: 50,
        fatigue: 50,
        volatility: 50,
        confidence: 90,
        band: ReadinessBand::Yellow as u8,
    });
    assert_eq!(yellow.focus_minutes, 25);
    assert_eq!(yellow.break_minutes, 10);

    let red = recommend_session(&PmReadinessOutput {
        readiness: 30,
        fatigue: 70,
        volatility: 80,
        confidence: 50,
        band: ReadinessBand::Red as u8,
    });
    assert_eq!(red.focus_minutes, 12);
    assert_eq!(red.break_minutes, 15);
}

#[test]
fn strong_inputs_produce_green_band() {
    let output = compute_readiness(&happy_input());
    assert_eq!(output.band, ReadinessBand::Green as u8);
    assert!(output.readiness >= 70);
    assert!(output.confidence >= 75);
}

#[test]
fn missing_signals_reduce_confidence_without_panicking() {
    let mut input = happy_input();
    input.availability_flags = AVAILABILITY_HEART_RATE | AVAILABILITY_SLEEP;
    input.hrv_sdnn_latest_ms = 0;
    input.hrv_sdnn_median_7d_ms = 0;
    input.resting_hr_latest_bpm = 0;
    input.resting_hr_median_7d_bpm = 0;
    input.respiratory_rate_latest_tenths = 0;
    input.respiratory_rate_median_7d_tenths = 0;

    let output = compute_readiness(&input);
    assert!(output.confidence < 100);
    assert!(output.readiness <= 100);
}

#[test]
fn stale_signal_ages_reduce_confidence() {
    let fresh = compute_readiness(&happy_input());

    let mut stale_input = happy_input();
    stale_input.hrv_age_hours = 72;
    stale_input.sleep_age_hours = 72;
    let stale = compute_readiness(&stale_input);

    assert!(stale.confidence < fresh.confidence);
}
