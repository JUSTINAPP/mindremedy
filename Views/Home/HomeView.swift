import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: PracticeCoordinator
    @Binding var selectedTab: AppTab

    @State private var mood: String? = nil
    @State private var lastSession: MindSession? = nil
    @State private var hasLoadedLastSession = false

    private let moods = ["Calm", "Average", "Stressed"]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    moodPills
                        .padding(.top, 20)

                    if let lastSession {
                        continueCard(for: lastSession)
                            .padding(.top, 28)
                    } else if hasLoadedLastSession {
                        firstPracticeCard
                            .padding(.top, 28)
                    }

                    explorePracticeRow
                        .padding(.top, 14)

                    patternsCard
                        .padding(.top, 10)
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
                .padding(.top, 28)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                CustomTabBar(selectedTab: $selectedTab)
            }
            .navigationDestination(for: Technique.self) { technique in
                TechniqueDetailView(technique: technique)
            }
            .navigationDestination(for: ConfigureRoute.self) { route in
                ConfigureView(technique: route.technique)
            }
            .navigationBarHidden(true)
            .task {
                lastSession = await SupabaseService.shared.fetchLastSession(userId: appState.userId)
                hasLoadedLastSession = true
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("How is your mind right now?")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Circle()
                .fill(Color.white.opacity(0.08))
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                .frame(width: 32, height: 32)
        }
    }

    private var moodPills: some View {
        HStack(spacing: 8) {
            ForEach(moods, id: \.self) { label in
                let selected = mood == label
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(selected ? AppTheme.accent : AppTheme.pillBackground)
                    .foregroundColor(selected ? AppTheme.onAccent : AppTheme.textPrimary.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.capsule)
                            .stroke(selected ? AppTheme.accent : AppTheme.pillBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.capsule))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { mood = label }
                    }
            }
        }
    }

    private func continueCard(for session: MindSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CONTINUE")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.6)
                .foregroundColor(AppTheme.accent)

            Text("\(session.durationMinutes) min \u{00B7} Breath Awareness")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 8)

            Text("Last practised \(relativeDay(session.startedAt))")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.top, 3)

            Button {
                let config = SessionConfig(
                    techniqueId: session.techniqueId,
                    techniqueName: Technique.breathAwareness.name,
                    durationMinutes: session.durationMinutes,
                    ambientSound: AmbientSound(rawValue: session.ambientSound) ?? .rain,
                    bellEnabled: session.bellEnabled
                )
                coordinator.start(config)
            } label: {
                HStack(spacing: 8) {
                    PlayIcon()
                    Text("START")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(AppTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
    }

    private var firstPracticeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("GET STARTED")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.6)
                .foregroundColor(AppTheme.accent)

            Text("Breath Awareness")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 8)

            Text("A simple first practice, 5\u{2013}20 minutes")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.top, 3)

            NavigationLink(value: Technique.breathAwareness) {
                HStack(spacing: 8) {
                    PlayIcon()
                    Text("START")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(AppTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
    }

    private var explorePracticeRow: some View {
        NavigationLink(value: Technique.breathAwareness) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Explore a practice")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Techniques, origins, evidence")
                        .font(.system(size: 12.5))
                        .foregroundColor(AppTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textFaint)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.row)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
        }
    }

    private var patternsCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Your patterns")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary.opacity(0.75))
            Text("Unlocks after a few sessions")
                .font(.system(size: 12.5))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.row)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundColor(Color.white.opacity(0.1))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
    }

    private func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "today" }
        if calendar.isDateInYesterday(date) { return "yesterday" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private struct PlayIcon: View {
    var body: some View {
        Image(systemName: "play.fill")
            .font(.system(size: 12))
    }
}
