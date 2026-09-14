import Foundation
import SwiftData

/// A single practice session, stored entirely on-device via SwiftData — no
/// account, no network call. A session and its post-session check-in are
/// one row rather than two tables, since this app never has more than one
/// check-in per session. See CLAUDE.md "Auth & signup" (2026-09-14) for why
/// this replaced the original Supabase-backed mind_sessions/mind_checkins
/// plan: sign-up was redirecting into the Remedy Reminder account instead
/// of creating a Mind Remedy identity, so auth was pulled from the pilot
/// entirely rather than debugging that coupling.
@Model
final class LocalSession {
    var id: UUID
    var techniqueId: String
    var techniqueName: String
    var configuredMinutes: Int
    var actualMinutes: Int
    var ambientSound: String
    var bellEnabled: Bool
    var startedAt: Date
    var completedAt: Date?

    var mood: String?
    var distractionLevel: String?
    var note: String?

    init(
        techniqueId: String,
        techniqueName: String,
        configuredMinutes: Int,
        ambientSound: String,
        bellEnabled: Bool
    ) {
        self.id = UUID()
        self.techniqueId = techniqueId
        self.techniqueName = techniqueName
        self.configuredMinutes = configuredMinutes
        self.actualMinutes = 0
        self.ambientSound = ambientSound
        self.bellEnabled = bellEnabled
        self.startedAt = Date()
    }
}
