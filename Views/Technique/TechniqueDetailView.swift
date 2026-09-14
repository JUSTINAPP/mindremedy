import SwiftUI

struct TechniqueDetailView: View {
    let technique: Technique

    @Environment(\.dismiss) private var dismiss
    @State private var expandedOutcomes: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                breadcrumb
                    .padding(.horizontal, AppTheme.Spacing.screenPadding)
                    .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(technique.name)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 16)

                        Text("\(technique.level) \u{00B7} \(technique.durationRange) \u{00B7} \(technique.category) practice")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 6)

                        Text(technique.overview)
                            .font(.system(size: 14.5))
                            .lineSpacing(4)
                            .foregroundColor(AppTheme.textPrimary.opacity(0.75))
                            .padding(.top, 18)

                        evidenceHeader
                            .padding(.top, 26)

                        VStack(spacing: 10) {
                            ForEach(technique.outcomes) { outcome in
                                outcomeCard(outcome)
                            }
                        }
                        .padding(.top, 12)

                        Text("HOW IT'S PRACTISED")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 26)

                        Text(technique.howItsPracticed)
                            .font(.system(size: 14.5))
                            .lineSpacing(4)
                            .foregroundColor(AppTheme.textPrimary.opacity(0.75))
                            .padding(.top, 10)

                        Color.clear.frame(height: 110)
                    }
                    .padding(.horizontal, AppTheme.Spacing.screenPadding)
                    .padding(.top, 16)
                }
            }

            startButton
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
                .padding(.bottom, 24)
                .padding(.top, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.background, AppTheme.background.opacity(0)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
        }
        .navigationBarHidden(true)
    }

    private var breadcrumb: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.6))
            }
            Text("EXPLORE \u{00B7} \(technique.category.uppercased())")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.4)
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
        }
    }

    private var evidenceHeader: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("EVIDENCE BY OUTCOME")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.6)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text("Illustrative \u{2014} pending review")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textFaint)
        }
    }

    private func outcomeCard(_ outcome: TechniqueOutcome) -> some View {
        let expanded = expandedOutcomes.contains(outcome.id)
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(outcome.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(outcome.tier)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 999)
                        .fill(AppTheme.accent)
                        .frame(width: geo.size.width * outcome.strength)
                }
            }
            .frame(height: 5)
            .padding(.top, 8)

            if expanded {
                Text(outcome.detail)
                    .font(.system(size: 12.5))
                    .lineSpacing(3)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 10)
            }
        }
        .padding(14)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.control)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                if expanded {
                    expandedOutcomes.remove(outcome.id)
                } else {
                    expandedOutcomes.insert(outcome.id)
                }
            }
        }
    }

    private var startButton: some View {
        NavigationLink(value: ConfigureRoute(technique: technique)) {
            Text("Start Practice")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
        }
    }
}
