use core::mem::{align_of, size_of};

use peakcore_model::{PmEstimatorInput, PmReadinessOutput, PmRecommendation, ReadinessBand};

#[test]
fn ffi_layouts_are_stable_for_mvp() {
    assert_eq!(size_of::<PmEstimatorInput>(), 32);
    assert_eq!(align_of::<PmEstimatorInput>(), 4);

    assert_eq!(size_of::<PmReadinessOutput>(), 5);
    assert_eq!(align_of::<PmReadinessOutput>(), 1);

    assert_eq!(size_of::<PmRecommendation>(), 6);
    assert_eq!(align_of::<PmRecommendation>(), 2);

    assert_eq!(ReadinessBand::Red as u8, 0);
    assert_eq!(ReadinessBand::Yellow as u8, 1);
    assert_eq!(ReadinessBand::Green as u8, 2);
}
