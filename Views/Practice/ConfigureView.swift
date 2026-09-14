import SwiftUI

struct ConfigureView: View {
    let technique: Technique

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: PracticeCoordinator

    @State private var duration = 20
    @State private var sound: AmbientSound = .rain
    @State private var bellEnabled = true

    private let durations = [5, 10, 15, 20, 30]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, AppTheme.Spacing.screenPadding)
                    .padding(.top, 24)

                Spacer()

                Text(durationLabel)
                    .font(.system(size: 72, weight: .thin))
                    .monospacedDigit()
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel("DURATION")
                    durationRow
                        .padding(.top, 10)

                    sectionLabel("AMBIENT SOUND")
                        .padding(.top, 20)
                    soundRow
                        .padding(.top, 10)

                    bellRow
                        .padding(.top, 20)

                    startButton
                        .padding(.top, 20)
                        .padding(.bottom, 26)
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            }
        }
        .navigationBarHidden(true)
    }

    private var durationLabel: String {
        String(format: "%02d:00", duration)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.6))
            }
            Spacer()
            Text(technique.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Color.clear.frame(width: 20)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.6)
            .foregroundColor(AppTheme.textTertiary)
    }

    private var durationRow: some View {
        HStack(spacing: 8) {
            ForEach(durations, id: \.self) { mins in
                let selected = duration == mins
                Text("\(mins)")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selected ? AppTheme.accent : AppTheme.pillBackground)
                    .foregroundColor(selected ? AppTheme.onAccent : AppTheme.textPrimary.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                            .stroke(selected ? AppTheme.accent : AppTheme.pillBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { duration = mins }
                    }
            }
        }
    }

    private var soundRow: some View {
        HStack(spacing: 8) {
            ForEach(AmbientSound.allCases, id: \.self) { option in
                let selected = sound == option
                VStack(spacing: 5) {
                    Image(systemName: iconName(for: option))
                        .font(.system(size: 16))
                        .foregroundColor(selected ? AppTheme.accent : AppTheme.textSecondary)
                    Text(option.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(selected ? AppTheme.accent : AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? AppTheme.accent.opacity(0.14) : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                        .stroke(selected ? AppTheme.accent : Color.white.opacity(0.1), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) { sound = option }
                }
            }
        }
    }

    private func iconName(for sound: AmbientSound) -> String {
        switch sound {
        case .rain: return "cloud.rain"
        case .ocean: return "water.waves"
        case .forest: return "leaf"
        case .silence: return "circle"
        }
    }

    private var bellRow: some View {
        HStack {
            Text("Start & end bell")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Toggle("", isOn: $bellEnabled.animation(.easeInOut(duration: 0.15)))
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.control)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
    }

    private var startButton: some View {
        Button {
            let config = SessionConfig(
                techniqueId: technique.id,
                techniqueName: technique.name,
                durationMinutes: duration,
                ambientSound: sound,
                bellEnabled: bellEnabled
            )
            coordinator.start(config)
        } label: {
            Text("START")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
        }
    }
}
