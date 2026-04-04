import Foundation

public struct SignalFlags: OptionSet, Codable, Hashable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let heartRate = SignalFlags(rawValue: 1 << 0)
    public static let hrv = SignalFlags(rawValue: 1 << 1)
    public static let restingHeartRate = SignalFlags(rawValue: 1 << 2)
    public static let respiratoryRate = SignalFlags(rawValue: 1 << 3)
    public static let sleep = SignalFlags(rawValue: 1 << 4)
    public static let watchHeartRate = SignalFlags(rawValue: 1 << 5)

    public static let requiredForActiveFocus: SignalFlags = [.heartRate, .hrv]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(UInt32.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var debugNames: [String] {
        var names: [String] = []
        if contains(.heartRate) { names.append("Heart Rate") }
        if contains(.hrv) { names.append("HRV") }
        if contains(.restingHeartRate) { names.append("Resting HR") }
        if contains(.respiratoryRate) { names.append("Respiratory Rate") }
        if contains(.sleep) { names.append("Sleep") }
        if contains(.watchHeartRate) { names.append("Watch Heart Rate") }
        return names
    }
}

public enum ReadinessBand: UInt8, Codable, Sendable {
    case red = 0
    case yellow = 1
    case green = 2
}

public enum StaleReasonCode: UInt8, Codable, Sendable {
    case none = 0
    case missingRequiredSignal = 1
    case staleSnapshot = 2
    case permissionStateChanged = 3
}

public enum AuthorizationState: String, Codable, Sendable {
    case unknown
    case denied
    case authorized
}

public struct ReadinessSnapshot: Codable, Equatable, Sendable {
    public var readiness: Int
    public var fatigue: Int
    public var volatility: Int
    public var confidence: Int
    public var band: ReadinessBand
    public var missingSignals: SignalFlags
    public var generatedAt: Date

    public init(
        readiness: Int,
        fatigue: Int,
        volatility: Int,
        confidence: Int,
        band: ReadinessBand,
        missingSignals: SignalFlags,
        generatedAt: Date
    ) {
        self.readiness = readiness
        self.fatigue = fatigue
        self.volatility = volatility
        self.confidence = confidence
        self.band = band
        self.missingSignals = missingSignals
        self.generatedAt = generatedAt
    }
}

public struct FocusRecommendation: Codable, Equatable, Sendable {
    public var focusMinutes: Int
    public var breakMinutes: Int
    public var staleReasonCode: StaleReasonCode
    public var generatedAt: Date

    public init(
        focusMinutes: Int,
        breakMinutes: Int,
        staleReasonCode: StaleReasonCode,
        generatedAt: Date
    ) {
        self.focusMinutes = focusMinutes
        self.breakMinutes = breakMinutes
        self.staleReasonCode = staleReasonCode
        self.generatedAt = generatedAt
    }
}

public struct WatchSyncPayload: Codable, Equatable, Sendable {
    public var snapshot: ReadinessSnapshot
    public var recommendation: FocusRecommendation

    public init(snapshot: ReadinessSnapshot, recommendation: FocusRecommendation) {
        self.snapshot = snapshot
        self.recommendation = recommendation
    }
}

public enum DashboardState: Equatable, Sendable {
    case blocked(String)
    case degraded([String])
    case ready
}

public struct FocusGateDecision: Equatable, Sendable {
    public var canStart: Bool
    public var staleReason: StaleReasonCode
    public var detail: String

    public init(canStart: Bool, staleReason: StaleReasonCode, detail: String) {
        self.canStart = canStart
        self.staleReason = staleReason
        self.detail = detail
    }
}
