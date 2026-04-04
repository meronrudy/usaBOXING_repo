#if os(watchOS)
import SwiftUI

@main
struct PeakmodoroWatchApp: App {
    @StateObject private var model = WatchAppModel()

    var body: some Scene {
        WindowGroup {
            WatchRootView(model: model)
                .task {
                    model.activate()
                }
        }
    }
}
#endif
