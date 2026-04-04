#if os(macOS)
import SwiftUI

@main
struct PeakmodoroMacApp: App {
    @StateObject private var model = PeakmodoroMacAppModel()

    var body: some Scene {
        WindowGroup {
            MacRootView(model: model)
                .task {
                    model.bootstrap()
                }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Reload Snapshot") {
                    model.reload()
                }
                .keyboardShortcut("r")
            }
        }
    }
}
#endif
