#if os(iOS)
import SwiftUI

@main
struct PeakmodoroiPhoneApp: App {
    @StateObject private var model = PeakmodoroAppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .task {
                    await model.bootstrap()
                }
        }
    }
}
#endif
