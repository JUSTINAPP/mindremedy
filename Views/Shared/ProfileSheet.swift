import SwiftUI

/// Minimal Profile/Settings surface reached from Home's header avatar.
/// Right now this exists for exactly one reason: to hold the single
/// stubbed "Premium" row. See CLAUDE.md "Auth & signup" (2026-09-14) — the
/// core loop itself needs no account at all, and Premium is deliberately
/// the *only* place in the app that would eventually trigger sign-up, kept
/// as an explicit, clearly-labeled step rather than an implicit shared
/// session with Remedy Reminder (which is what caused the sign-up redirect
/// bug that led to pulling auth from this pilot). No real premium features
/// exist yet — this just reserves the entry point.
struct ProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    premiumRow
                        .padding(.top, 24)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accent)
                }
            }
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var premiumRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Premium")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.7))
                Text("Coming soon")
                    .font(.system(size: 12.5))
                    .foregroundColor(AppTheme.textTertiary)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textFaint)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.row)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
        .opacity(0.6)
    }
}

#Preview {
    ProfileSheet()
}
