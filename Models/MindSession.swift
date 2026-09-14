import Foundation

enum AmbientSound: String, CaseIterable, Codable {
    case rain = "Rain"
    case ocean = "Ocean"
    case forest = "Forest"
    case silence = "Silence"
}

/// The user's picks on the Configure screen, carried into the active session.
struct SessionConfig {
    var techniqueId: String
    var techniqueName: String
    var durationMinutes: Int
    var ambientSound: AmbientSound
    var bellEnabled: Bool
}

/// Mirrors a row in the `mind_sessions` table.
struct MindSession: Codable, Identifiable {
    let id: UUID
    let userId: String
    let techniqueId: String
    let durationMinutes: Int
    let ambientSound: String
    let bellEnabled: Bool
    let startedAt: Date
    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case techniqueId = "technique_id"
        case durationMinutes = "duration_minutes"
        case ambientSound = "ambient_sound"
        case bellEnabled = "bell_enabled"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

/// What's handed off from the active session to the post-session check-in
/// once a session ends, whether it finished naturally or was ended early.
struct CompletedSession: Identifiable {
    let id = UUID()
    let sessionId: UUID?
    let techniqueName: String
    let durationMinutes: Int
}
