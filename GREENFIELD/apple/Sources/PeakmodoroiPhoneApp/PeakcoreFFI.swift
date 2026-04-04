#if os(iOS)
import Foundation

enum PeakcoreFFIError: Error {
    case computeFailed(Int32)
    case recommendationFailed(Int32)
    case invalidBand(UInt8)
}

@frozen
struct PmEstimatorInputFFI {
    var sleep_duration_minutes: UInt16
    var sleep_recency_minutes: UInt16
    var hrv_sdnn_latest_ms: UInt16
    var hrv_sdnn_median_7d_ms: UInt16
    var resting_hr_latest_bpm: UInt16
    var resting_hr_median_7d_bpm: UInt16
    var respiratory_rate_latest_tenths: UInt16
    var respiratory_rate_median_7d_tenths: UInt16
    var live_hr_delta_bpm: Int16
    var hrv_age_hours: UInt16
    var resting_hr_age_hours: UInt16
    var respiratory_age_hours: UInt16
    var sleep_age_hours: UInt16
    var availability_flags: UInt32
}

@frozen
struct PmReadinessOutputFFI {
    var readiness: UInt8 = 0
    var fatigue: UInt8 = 0
    var volatility: UInt8 = 0
    var confidence: UInt8 = 0
    var band: UInt8 = 0
}

@frozen
struct PmRecommendationFFI {
    var focus_minutes: UInt16 = 0
    var break_minutes: UInt16 = 0
    var stale_reason_code: UInt8 = 0
    var _padding: UInt8 = 0
}

@_silgen_name("pm_version_major") private func pm_version_major() -> Int32
@_silgen_name("pm_version_minor") private func pm_version_minor() -> Int32
@_silgen_name("pm_compute_readiness")
private func pm_compute_readiness(_ input: UnsafePointer<PmEstimatorInputFFI>?, _ output: UnsafeMutablePointer<PmReadinessOutputFFI>?) -> Int32
@_silgen_name("pm_recommend_session")
private func pm_recommend_session(_ readiness: UnsafePointer<PmReadinessOutputFFI>?, _ recommendation: UnsafeMutablePointer<PmRecommendationFFI>?) -> Int32

struct PeakEstimatorInput {
    var sleepDurationMinutes: UInt16
    var sleepRecencyMinutes: UInt16
    var hrvLatestMs: UInt16
    var hrvMedian7dMs: UInt16
    var restingHRLatestBpm: UInt16
    var restingHRMedian7dBpm: UInt16
    var respiratoryLatestTenths: UInt16
    var respiratoryMedian7dTenths: UInt16
    var liveHRDeltaBpm: Int16
    var hrvAgeHours: UInt16
    var restingHRAgeHours: UInt16
    var respiratoryAgeHours: UInt16
    var sleepAgeHours: UInt16
    var availabilityFlags: UInt32
    var missingSignals: SignalFlags
}

struct PeakcoreEstimator {
    func version() -> String {
        "\(pm_version_major()).\(pm_version_minor())"
    }

    func computePayload(from input: PeakEstimatorInput, generatedAt: Date) throws -> WatchSyncPayload {
        var ffiInput = PmEstimatorInputFFI(
            sleep_duration_minutes: input.sleepDurationMinutes,
            sleep_recency_minutes: input.sleepRecencyMinutes,
            hrv_sdnn_latest_ms: input.hrvLatestMs,
            hrv_sdnn_median_7d_ms: input.hrvMedian7dMs,
            resting_hr_latest_bpm: input.restingHRLatestBpm,
            resting_hr_median_7d_bpm: input.restingHRMedian7dBpm,
            respiratory_rate_latest_tenths: input.respiratoryLatestTenths,
            respiratory_rate_median_7d_tenths: input.respiratoryMedian7dTenths,
            live_hr_delta_bpm: input.liveHRDeltaBpm,
            hrv_age_hours: input.hrvAgeHours,
            resting_hr_age_hours: input.restingHRAgeHours,
            respiratory_age_hours: input.respiratoryAgeHours,
            sleep_age_hours: input.sleepAgeHours,
            availability_flags: input.availabilityFlags
        )
        var output = PmReadinessOutputFFI()
        let computeStatus = withUnsafePointer(to: &ffiInput) { inputPointer in
            withUnsafeMutablePointer(to: &output) { outputPointer in
                pm_compute_readiness(inputPointer, outputPointer)
            }
        }
        guard computeStatus == 0 else {
            throw PeakcoreFFIError.computeFailed(computeStatus)
        }

        var recommendationFFI = PmRecommendationFFI()
        let recommendationStatus = withUnsafePointer(to: &output) { outputPointer in
            withUnsafeMutablePointer(to: &recommendationFFI) { recommendationPointer in
                pm_recommend_session(outputPointer, recommendationPointer)
            }
        }
        guard recommendationStatus == 0 else {
            throw PeakcoreFFIError.recommendationFailed(recommendationStatus)
        }

        guard let band = ReadinessBand(rawValue: output.band) else {
            throw PeakcoreFFIError.invalidBand(output.band)
        }

        let snapshot = ReadinessSnapshot(
            readiness: Int(output.readiness),
            fatigue: Int(output.fatigue),
            volatility: Int(output.volatility),
            confidence: Int(output.confidence),
            band: band,
            missingSignals: input.missingSignals,
            generatedAt: generatedAt
        )
        let recommendation = FocusRecommendation(
            focusMinutes: Int(recommendationFFI.focus_minutes),
            breakMinutes: Int(recommendationFFI.break_minutes),
            staleReasonCode: StaleReasonCode(rawValue: recommendationFFI.stale_reason_code) ?? .none,
            generatedAt: generatedAt
        )
        return WatchSyncPayload(snapshot: snapshot, recommendation: recommendation)
    }
}
#endif
