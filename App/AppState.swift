import SwiftUI
import Combine
import Supabase
import Auth

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userId: String = ""
    @Published var userEmail: String = ""
    /// True until the initial Supabase session-restore check resolves on
    /// cold launch, so the app never flashes the login screen before
    /// flipping to the logged-in home screen. Same pattern as Remedy
    /// Reminder's AppState.
    @Published var isLoading: Bool = true

    init() {
        Task { await checkExistingSession() }
    }

    /// Supabase's SDK persists its own session (Keychain-backed) and
    /// refreshes it transparently, so restoring on cold launch is just
    /// asking it for the current session.
    func checkExistingSession() async {
        do {
            let session = try await SupabaseService.shared.client.auth.session
            // Swift's UUID.uuidString is always uppercase, but Postgres's
            // auth.uid()::text is always lowercase — RLS compares these as
            // exact text, so this must be lowercased here. See Remedy
            // Reminder's AppState.checkExistingSession for the incident
            // that established this pattern.
            self.userId = session.user.id.uuidString.lowercased()
            self.userEmail = session.user.email ?? ""
            self.isAuthenticated = true
        } catch {
            self.isAuthenticated = false
            self.userId = ""
        }
        self.isLoading = false
    }

    func signOut() async {
        try? await SupabaseService.shared.client.auth.signOut()
        self.userId = ""
        self.userEmail = ""
        self.isAuthenticated = false
    }

    /// Deletes only Mind Remedy's own data, then the Supabase auth session
    /// itself. Deliberately independent of Remedy Reminder's own account
    /// deletion — see SupabaseService.deleteAllUserData and CLAUDE.md
    /// "Backend — Supabase". Not yet wired to a UI entry point since a
    /// Profile/Settings screen isn't part of this build's scope, but the
    /// deletion logic is ready for when one is added.
    func deleteAccount() async throws {
        try await SupabaseService.shared.deleteAllUserData(userId: userId)
        try? await SupabaseService.shared.client.auth.signOut()
        self.userId = ""
        self.userEmail = ""
        self.isAuthenticated = false
    }
}
