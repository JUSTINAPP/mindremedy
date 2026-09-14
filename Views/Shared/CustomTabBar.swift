import SwiftUI

/// The bottom nav row from design-reference/Main.dc.html. Attached via
/// `.safeAreaInset(edge: .bottom)` on each tab's root screen only (never on
/// pushed detail screens like Technique/Configure), same convention Remedy
/// Reminder uses for sticky bottom bars.
struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let selected = tab == selectedTab
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        NavIcon(kind: tab.iconKind, color: selected ? AppTheme.accent : AppTheme.textFaint)
                        Text(tab.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(selected ? AppTheme.accent : AppTheme.textFaint)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(
            AppTheme.background
                .overlay(Rectangle().frame(height: 1).foregroundColor(AppTheme.hairline), alignment: .top)
        )
    }
}
