import Foundation

public enum SnapshotPolicy {
    public static func dashboardState(snapshot: ReadinessSnapshot?) -> DashboardState {
        guard let snapshot else {
            return .blocked("Authorize Health data to compute readiness.")
        }

        let visibleMissing = snapshot.missingSignals.subtracting(.heartRate)
        if visibleMissing.isEmpty {
            return .ready
        }

        return .degraded(visibleMissing.debugNames)
    }

    public static func isStale(
        generatedAt: Date,
        now: Date,
        calendar: Calendar,
        permissionChangedAt: Date?
    ) -> Bool {
        if !calendar.isDate(generatedAt, inSameDayAs: now) {
            return true
        }
        if let permissionChangedAt, generatedAt < permissionChangedAt {
            return true
        }
        return false
    }

    public static func activeFocusGate(
        payload: WatchSyncPayload?,
        now: Date,
        calendar: Calendar,
        permissionChangedAt: Date?,
        watchHeartRateAvailable: Bool
    ) -> FocusGateDecision {
        guard let payload else {
            return FocusGateDecision(
                canStart: false,
                staleReason: .missingRequiredSignal,
                detail: "No readiness snapshot is available."
            )
        }

        if isStale(
            generatedAt: payload.recommendation.generatedAt,
            now: now,
            calendar: calendar,
            permissionChangedAt: permissionChangedAt
        ) {
            return FocusGateDecision(
                canStart: false,
                staleReason: permissionChangedAt == nil ? .staleSnapshot : .permissionStateChanged,
                detail: "Open the iPhone app to refresh today's recommendation."
            )
        }

        if payload.snapshot.missingSignals.contains(.hrv) {
            return FocusGateDecision(
                canStart: false,
                staleReason: .missingRequiredSignal,
                detail: "HRV is required for active focus mode."
            )
        }

        if !watchHeartRateAvailable {
            return FocusGateDecision(
                canStart: false,
                staleReason: .missingRequiredSignal,
                detail: "Watch heart rate is unavailable."
            )
        }

        return FocusGateDecision(canStart: true, staleReason: .none, detail: "Ready to start.")
    }
}
