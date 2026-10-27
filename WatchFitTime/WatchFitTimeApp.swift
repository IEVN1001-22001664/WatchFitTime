import SwiftUI

@main
struct WatchFitTimeApp: App {
    @State private var controller = WorkoutController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(controller)
                .onAppear { RestNotifier.requestAuthorization() }
        }
    }
}
