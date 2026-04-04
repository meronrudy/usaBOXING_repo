use core::ffi::c_int;

use peakcore_estimator::{compute_readiness, recommend_session};
use peakcore_model::{
    PmEstimatorInput, PmReadinessOutput, PmRecommendation, PM_VERSION_MAJOR, PM_VERSION_MINOR,
};

pub const PM_SUCCESS: c_int = 0;
pub const PM_ERROR_NULL_POINTER: c_int = -1;

#[unsafe(no_mangle)]
pub extern "C" fn pm_version_major() -> c_int {
    PM_VERSION_MAJOR
}

#[unsafe(no_mangle)]
pub extern "C" fn pm_version_minor() -> c_int {
    PM_VERSION_MINOR
}

#[unsafe(no_mangle)]
pub extern "C" fn pm_compute_readiness(
    input: *const PmEstimatorInput,
    output: *mut PmReadinessOutput,
) -> c_int {
    if input.is_null() || output.is_null() {
        return PM_ERROR_NULL_POINTER;
    }

    let computed = compute_readiness(unsafe { &*input });
    unsafe { *output = computed };
    PM_SUCCESS
}

#[unsafe(no_mangle)]
pub extern "C" fn pm_recommend_session(
    readiness: *const PmReadinessOutput,
    recommendation: *mut PmRecommendation,
) -> c_int {
    if readiness.is_null() || recommendation.is_null() {
        return PM_ERROR_NULL_POINTER;
    }

    let computed = recommend_session(unsafe { &*readiness });
    unsafe { *recommendation = computed };
    PM_SUCCESS
}
