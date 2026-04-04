import Foundation
import PeakmodoroShared

private func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("Validation failed: \(message)\n", stderr)
        exit(1)
    }
}

var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(secondsFromGMT: 0)!
let generatedAt = ISO8601DateFormatter().date(from: "2026-03-31T23:55:00Z")!
let nextDay = ISO8601DateFormatter().date(from: "2026-04-01T01:00:00Z")!
expect(
    SnapshotPolicy.isStale(generatedAt: generatedAt, now: nextDay, calendar: calendar, permissionChangedAt: nil),
    "Cross-day snapshots must be stale"
)

let referenceDate = Date(timeIntervalSince1970: 1_743_388_800)
let blockedPayload = WatchSyncPayload(
    snapshot: ReadinessSnapshot(
        readiness: 55,
        fatigue: 45,
        volatility: 50,
        confidence: 60,
        band: .yellow,
        missingSignals: [.hrv],
        generatedAt: referenceDate
    ),
    recommendation: FocusRecommendation(
        focusMinutes: 25,
        breakMinutes: 10,
        staleReasonCode: .none,
        generatedAt: referenceDate
    )
)
let gate = SnapshotPolicy.activeFocusGate(
    payload: blockedPayload,
    now: referenceDate,
    calendar: .current,
    permissionChangedAt: nil,
    watchHeartRateAvailable: true
)
expect(!gate.canStart, "Missing HRV must block active focus")

let degradedState = SnapshotPolicy.dashboardState(
    snapshot: ReadinessSnapshot(
        readiness: 61,
        fatigue: 39,
        volatility: 30,
        confidence: 70,
        band: .yellow,
        missingSignals: [.sleep, .respiratoryRate],
        generatedAt: .now
    )
)
switch degradedState {
case .degraded(let names):
    expect(Set(names) == Set(["Sleep", "Respiratory Rate"]), "Optional missing signals should surface in UI state")
default:
    expect(false, "Dashboard should be degraded when optional signals are missing")
}

let payload = WatchSyncPayload(
    snapshot: ReadinessSnapshot(
        readiness: 74,
        fatigue: 30,
        volatility: 22,
        confidence: 88,
        band: .green,
        missingSignals: [],
        generatedAt: .now
    ),
    recommendation: FocusRecommendation(
        focusMinutes: 40,
        breakMinutes: 7,
        staleReasonCode: .none,
        generatedAt: .now
    )
)
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let data = try encoder.encode(payload)
let decoded = try decoder.decode(WatchSyncPayload.self, from: data)
expect(decoded.snapshot.readiness == payload.snapshot.readiness, "Payload should survive JSON round-trip")

print("Peakmodoro shared validation passed")
