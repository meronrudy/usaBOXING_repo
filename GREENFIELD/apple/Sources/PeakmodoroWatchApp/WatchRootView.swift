#if os(watchOS)
import SwiftUI

struct WatchRootView: View {
    @ObservedObject var model: WatchAppModel

    var body: some View {
        VStack(spacing: 12) {
            if let payload = model.payload {
                Text(label(for: payload.snapshot.band))
                    .font(.headline)
                Text("\(payload.snapshot.readiness)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("\(payload.recommendation.focusMinutes)m / \(payload.recommendation.breakMinutes)m")
                    .font(.footnote)
            } else {
                Text("Waiting for iPhone sync")
            }

            Text(model.gate.detail)
                .font(.caption2)
                .multilineTextAlignment(.center)

            if model.phase == .idle {
                Button("Start Focus") {
                    model.startSession()
                }
                .disabled(!model.gate.canStart)
            } else {
                Text(timeString(model.remainingSeconds))
                    .font(.title2.monospacedDigit())
                if let heartRate = model.workout.currentHeartRate {
                    Text("HR \(Int(heartRate.rounded()))")
                        .font(.caption)
                }
                Button("Stop") {
                    model.stopSession()
                }
            }
        }
        .padding()
        .onAppear {
            model.refreshPayload()
        }
        .onReceive(model.bridge.$payload) { _ in
            model.refreshPayload()
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

    private func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}
#endif
