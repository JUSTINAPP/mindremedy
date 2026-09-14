import SwiftUI
import SwiftData

@main
struct mindremedyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: LocalSession.self)
    }
}
