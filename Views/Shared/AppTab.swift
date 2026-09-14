import Foundation

/// Nav destinations beyond Home are stubs for now — see CLAUDE.md "Scope".
enum AppTab: Int, CaseIterable {
    case home, practice, explore, progress

    var label: String {
        switch self {
        case .home: return "Home"
        case .practice: return "Practice"
        case .explore: return "Explore"
        case .progress: return "Progress"
        }
    }

    var iconKind: NavIcon.Kind {
        switch self {
        case .home: return .home
        case .practice: return .practice
        case .explore: return .explore
        case .progress: return .progress
        }
    }
}
