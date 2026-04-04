#if os(iOS)
import SwiftUI

struct RootView: View {
    @ObservedObject var model: PeakmodoroAppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Peakmodoro")
                        .font(.largeTitle.bold())

                    readinessCard
                    recommendationCard
                    signalCard
                    syncCard
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task { await model.refresh() }
                    }
                }
            }
        }
    }

    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Readiness")
                .font(.headline)

            if let snapshot = model.payload?.snapshot {
                Text("\(snapshot.readiness)%")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                Text("Band: \(label(for: snapshot.band))")
                Text("Confidence: \(snapshot.confidence)%")
            } else {
                Text(message(for: model.dashboardState))
            }

            if model.authorizationState != .authorized {
                Button("Authorize HealthKit") {
                    Task { await model.requestAuthorization() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recommendation")
                .font(.headline)
            if let recommendation = model.payload?.recommendation {
                Text("Focus \(recommendation.focusMinutes)m / Break \(recommendation.breakMinutes)m")
                Text("Generated \(recommendation.generatedAt.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.secondary)
            } else {
                Text("No recommendation yet.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var signalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Signal Debug")
                .font(.headline)
            if let snapshot = model.payload?.snapshot {
                if snapshot.missingSignals.isEmpty {
                    Text("All core signals available.")
                } else {
                    ForEach(snapshot.missingSignals.debugNames, id: \.self) { name in
                        Text("Missing: \(name)")
                    }
                }
            } else {
                Text("Waiting for HealthKit data.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var syncCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Watch Sync")
                .font(.headline)
            Text("State: \(model.watchSync.activationStateDescription)")
            Text(model.watchSync.isReachable ? "Watch reachable" : "Watch not reachable")
                .foregroundStyle(model.watchSync.isReachable ? .green : .secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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

    private func message(for state: DashboardState) -> String {
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
