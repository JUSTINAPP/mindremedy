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
