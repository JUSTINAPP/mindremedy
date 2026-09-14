import SwiftUI
import Combine

/// The Active session and Post-session check-in are both presented full
/// screen, chrome hidden, from wherever the user starts a practice (the
/// Home tab's Continue card, or Technique detail -> Configure). Held as one
/// Identifiable enum so a single `.fullScreenCover(item:)` can transition
/// between the two stages in place, rather than dismissing one cover and
/// presenting a second — see Remedy Reminder's CLAUDE.md on the
/// `.sheet(isPresented:)` presentation race this avoids.
enum PracticeStage: Identifiable {
    case active(SessionConfig)
    case checkIn(LocalSession)

    var id: String {
        switch self {
        case .active(let config):
            return "active-\(config.techniqueId)"
        case .checkIn(let session):
            return "checkin-\(session.id.uuidString)"
        }
    }
}

@MainActor
class PracticeCoordinator: ObservableObject {
    @Published var stage: PracticeStage?

    func start(_ config: SessionConfig) {
        stage = .active(config)
    }

    func finishActive(with session: LocalSession) {
        stage = .checkIn(session)
    }

    func dismiss() {
        stage = nil
    }
}
