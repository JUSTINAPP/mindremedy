import Foundation

/// Mirrors a row in the `mind_checkins` table — currently only used for the
/// post-session check-in (mood + distraction level + optional note).
struct MindCheckIn: Codable, Identifiable {
    let id: UUID
    let userId: String
    let sessionId: UUID?
    let mood: String
    let distractionLevel: String?
    let note: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sessionId = "session_id"
        case mood
        case distractionLevel = "distraction_level"
        case note
        case createdAt = "created_at"
    }
}
