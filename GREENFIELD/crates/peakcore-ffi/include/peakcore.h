#ifndef PEAKCORE_H
#define PEAKCORE_H

#include <stdint.h>

#define PM_AVAILABILITY_HEART_RATE (1u << 0)
#define PM_AVAILABILITY_HRV (1u << 1)
#define PM_AVAILABILITY_RESTING_HR (1u << 2)
#define PM_AVAILABILITY_RESPIRATORY_RATE (1u << 3)
#define PM_AVAILABILITY_SLEEP (1u << 4)
#define PM_AVAILABILITY_WATCH_HEART_RATE (1u << 5)

#define PM_STALE_REASON_NONE 0
#define PM_STALE_REASON_MISSING_REQUIRED_SIGNAL 1
#define PM_STALE_REASON_STALE_SNAPSHOT 2
#define PM_STALE_REASON_PERMISSION_STATE_CHANGED 3

#define PM_BAND_RED 0
#define PM_BAND_YELLOW 1
#define PM_BAND_GREEN 2

typedef struct PmEstimatorInput {
  uint16_t sleep_duration_minutes;
  uint16_t sleep_recency_minutes;
  uint16_t hrv_sdnn_latest_ms;
  uint16_t hrv_sdnn_median_7d_ms;
  uint16_t resting_hr_latest_bpm;
  uint16_t resting_hr_median_7d_bpm;
  uint16_t respiratory_rate_latest_tenths;
  uint16_t respiratory_rate_median_7d_tenths;
  int16_t live_hr_delta_bpm;
  uint16_t hrv_age_hours;
  uint16_t resting_hr_age_hours;
  uint16_t respiratory_age_hours;
  uint16_t sleep_age_hours;
  uint32_t availability_flags;
} PmEstimatorInput;

typedef struct PmReadinessOutput {
  uint8_t readiness;
  uint8_t fatigue;
  uint8_t volatility;
  uint8_t confidence;
  uint8_t band;
} PmReadinessOutput;

typedef struct PmRecommendation {
  uint16_t focus_minutes;
  uint16_t break_minutes;
  uint8_t stale_reason_code;
} PmRecommendation;

int32_t pm_version_major(void);
int32_t pm_version_minor(void);
int32_t pm_compute_readiness(const PmEstimatorInput *input, PmReadinessOutput *output);
int32_t pm_recommend_session(const PmReadinessOutput *readiness, PmRecommendation *recommendation);

#endif
