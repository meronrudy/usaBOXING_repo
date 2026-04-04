import Foundation

public enum OperationalStateKey: String, CaseIterable, Sendable {
    case heartRateAnchor
    case hrvAnchor
    case restingHeartRateAnchor
    case respiratoryRateAnchor
    case sleepAnchor
    case latestSnapshot
    case latestRecommendation
    case permissionChangedAt
    case latestSyncAt
    case activeSessionMarker
}

public final class OperationalStateStore: @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func setAnchorData(_ data: Data?, for key: OperationalStateKey) {
        defaults.set(data, forKey: key.rawValue)
    }

    public func anchorData(for key: OperationalStateKey) -> Data? {
        defaults.data(forKey: key.rawValue)
    }

    public func setSnapshot(_ snapshot: ReadinessSnapshot) {
        defaults.set(try? encoder.encode(snapshot), forKey: OperationalStateKey.latestSnapshot.rawValue)
    }

    public func snapshot() -> ReadinessSnapshot? {
        guard let data = defaults.data(forKey: OperationalStateKey.latestSnapshot.rawValue) else {
            return nil
        }
        return try? decoder.decode(ReadinessSnapshot.self, from: data)
    }

    public func setRecommendation(_ recommendation: FocusRecommendation) {
        defaults.set(try? encoder.encode(recommendation), forKey: OperationalStateKey.latestRecommendation.rawValue)
    }

    public func recommendation() -> FocusRecommendation? {
        guard let data = defaults.data(forKey: OperationalStateKey.latestRecommendation.rawValue) else {
            return nil
        }
        return try? decoder.decode(FocusRecommendation.self, from: data)
    }

    public func setDate(_ value: Date?, for key: OperationalStateKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    public func date(for key: OperationalStateKey) -> Date? {
        defaults.object(forKey: key.rawValue) as? Date
    }

    public func setActiveSessionMarker(_ marker: String?) {
        defaults.set(marker, forKey: OperationalStateKey.activeSessionMarker.rawValue)
    }

    public func activeSessionMarker() -> String? {
        defaults.string(forKey: OperationalStateKey.activeSessionMarker.rawValue)
    }
}
