import SwiftUI

struct MainTabView: View {
    @StateObject private var coordinator = PracticeCoordinator()
    @State private var selectedTab: AppTab = .home

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(selectedTab: $selectedTab)
            case .practice, .explore, .progress:
                ComingSoonView(title: selectedTab.label, selectedTab: $selectedTab)
            }
        }
        .environmentObject(coordinator)
        .fullScreenCover(item: $coordinator.stage) { stage in
            switch stage {
            case .active(let config):
                ActiveSessionView(config: config) { session in
                    coordinator.finishActive(with: session)
                }
            case .checkIn(let session):
                PostSessionCheckInView(session: session) {
                    coordinator.dismiss()
                }
            }
        }
    }
}
