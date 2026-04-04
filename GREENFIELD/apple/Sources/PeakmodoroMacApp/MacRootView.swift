#if os(macOS)
import SwiftUI

struct MacRootView: View {
    @ObservedObject var model: PeakmodoroMacAppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            Divider()

            if let payload = model.payload {
                HStack(alignment: .top, spacing: 40) {
                    readiness(snapshot: payload.snapshot)
                    recommendation(payload.recommendation)
                }
                signals(snapshot: payload.snapshot)
                focusGate(model.gate)
            } else {
                emptyState
            }
        }
        .padding(24)
        .frame(minWidth: 680, minHeight: 460)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Peakmodoro")
                    .font(.largeTitle.bold())
                Text("Desktop review")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Reload") {
                model.reload()
            }
            Button("Sample") {
                model.useSamplePayload()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            Text("No local snapshot")
                .font(.title2.bold())
            Text("Load a sample snapshot to review readiness locally.")
                .foregroundStyle(.secondary)
            Button("Sample") {
                model.useSamplePayload()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private func readiness(snapshot: ReadinessSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Readiness")
                .font(.headline)
            Text("\(snapshot.readiness)%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            LabeledContent("Band", value: label(for: snapshot.band))
            LabeledContent("Confidence", value: "\(snapshot.confidence)%")
            LabeledContent("Fatigue", value: "\(snapshot.fatigue)%")
            LabeledContent("Volatility", value: "\(snapshot.volatility)%")
            LabeledContent("Generated", value: snapshot.generatedAt.formatted(date: .abbreviated, time: .shortened))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func recommendation(_ recommendation: FocusRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recommendation")
                .font(.headline)
            LabeledContent("Focus", value: "\(recommendation.focusMinutes)m")
            LabeledContent("Break", value: "\(recommendation.breakMinutes)m")
            LabeledContent("Stale Reason", value: label(for: recommendation.staleReasonCode))
            LabeledContent("Generated", value: recommendation.generatedAt.formatted(date: .abbreviated, time: .shortened))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func signals(snapshot: ReadinessSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Signals")
                .font(.headline)
            if snapshot.missingSignals.isEmpty {
                Text("Core signals ready.")
            } else {
                ForEach(snapshot.missingSignals.debugNames, id: \.self) { signal in
                    Text("Missing: \(signal)")
                }
            }
            Text(statusLine(for: model.dashboardState))
                .foregroundStyle(.secondary)
        }
    }

    private func focusGate(_ gate: FocusGateDecision) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focus Gate")
                .font(.headline)
            Text(gate.canStart ? "Ready" : "Blocked")
            Text(gate.detail)
                .foregroundStyle(.secondary)
        }
    }

    private func label(for band: ReadinessBand) -> String {
        switch band {
        case .red:
            "Red"
        case .yellow:
            "Yellow"
        case .green:
            "Green"
        }
    }

    private func label(for staleReason: StaleReasonCode) -> String {
        switch staleReason {
        case .none:
            "None"
        case .missingRequiredSignal:
            "Missing Required Signal"
        case .staleSnapshot:
            "Stale Snapshot"
        case .permissionStateChanged:
            "Permission State Changed"
        }
    }

    private func statusLine(for state: DashboardState) -> String {
        switch state {
        case .blocked(let detail):
            detail
        case .degraded(let missing):
            "Degraded: \(missing.joined(separator: ", "))"
        case .ready:
            "Ready"
        }
    }
}
#endif
