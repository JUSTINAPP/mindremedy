import SwiftUI

struct ActiveSessionView: View {
    let config: SessionConfig
    let onEnd: (CompletedSession) -> Void

    @EnvironmentObject var appState: AppState

    @State private var chromeVisible = false
    @State private var everToggled = false
    @State private var breathing = false

    @State private var remainingSeconds: Int
    @State private var isPaused = false
    @State private var sessionId: UUID?
    @State private var timerTask: Task<Void, Never>?

    init(config: SessionConfig, onEnd: @escaping (CompletedSession) -> Void) {
        self.config = config
        self.onEnd = onEnd
        _remainingSeconds = State(initialValue: config.durationMinutes * 60)
    }

    private var totalSeconds: Int { config.durationMinutes * 60 }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    private var timeLabel: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("\(config.techniqueName) \u{00B7} \(config.ambientSound.rawValue)")
                    .font(.system(size: 12.5, weight: .semibold))
                    .tracking(0.4)
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.top, 26)
                    .opacity(chromeVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: chromeVisible)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 2)
                        .frame(width: 220, height: 220)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                        .animation(.linear(duration: 1), value: progress)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppTheme.accent.opacity(0.28), AppTheme.accent.opacity(0.05)],
                                center: UnitPoint(x: 0.35, y: 0.3),
                                startRadius: 1,
                                endRadius: 90
                            )
                        )
                        .overlay(Circle().stroke(AppTheme.accent.opacity(0.25), lineWidth: 1))
                        .frame(width: 150, height: 150)
                        .scaleEffect(breathing ? 1.06 : 0.92)
                        .opacity(breathing ? 0.9 : 0.55)
                        .animation(.easeInOut(duration: 3.25).repeatForever(autoreverses: true), value: breathing)

                    Text(timeLabel)
                        .font(.system(size: 34, weight: .thin))
                        .monospacedDigit()
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                HStack(spacing: 14) {
                    Button {
                        togglePause()
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary.opacity(0.8))
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(0.07))
                            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .clipShape(Circle())
                    }

                    Button {
                        endSession()
                    } label: {
                        Text("End Session")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary.opacity(0.85))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.capsule)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.capsule))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(chromeVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.35), value: chromeVisible)
            }

            if !chromeVisible && !everToggled {
                VStack {
                    Spacer()
                    Text("Tap anywhere to show controls")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textFaint)
                        .padding(.bottom, 16)
                }
                .allowsHitTesting(false)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.35)) {
                chromeVisible.toggle()
                everToggled = true
            }
        }
        .statusBarHidden()
        .task {
            breathing = true
            sessionId = await SupabaseService.shared.startSession(userId: appState.userId, config: config)
            startTimer()
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                if !isPaused {
                    remainingSeconds -= 1
                }
            }
            if !Task.isCancelled {
                endSession()
            }
        }
    }

    private func togglePause() {
        isPaused.toggle()
    }

    private func endSession() {
        timerTask?.cancel()
        let elapsedMinutes = max(1, (totalSeconds - remainingSeconds) / 60)
        let completed = CompletedSession(
            sessionId: sessionId,
            techniqueName: config.techniqueName,
            durationMinutes: elapsedMinutes
        )
        if let sessionId {
            Task { await SupabaseService.shared.completeSession(sessionId: sessionId) }
        }
        onEnd(completed)
    }
}
