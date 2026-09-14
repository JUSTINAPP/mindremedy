import SwiftUI

/// Stub for the Practice/Explore/Progress tab destinations — explicitly out
/// of scope for this build. See CLAUDE.md "Scope".
struct ComingSoonView: View {
    let title: String
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Coming soon")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}
