import Foundation
import Supabase

/// Shares Remedy Reminder's existing Supabase project (same URL/publishable
/// key) rather than standing up a separate one — a deliberate tradeoff, not
/// an oversight. Every new table is prefixed `mind_` to stay unambiguous
/// alongside Remedy Reminder's own tables in the same database. See
/// CLAUDE.md "Backend — Supabase" for the full reasoning.
class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://agzwefnisrlijbpqjjat.supabase.co")!,
            supabaseKey: "sb_publishable_ez0o_XXEOeWRKv52G-jpUQ_Rhowd-1Q"
        )
    }

    /// Deletes only Mind Remedy's own rows (the mind_* tables). Deliberately
    /// does NOT touch Remedy Reminder's tables in the same shared project —
    /// the two apps' account-deletion flows stay independent by default. See
    /// CLAUDE.md "Backend — Supabase" for why.
    func deleteAllUserData(userId: String) async throws {
        let tables = ["mind_sessions", "mind_checkins"]
        var failures: [String] = []

        for table in tables {
            do {
                try await client.from(table).delete().eq("user_id", value: userId).execute()
            } catch {
                print("[AccountDeletion] Failed to delete from \(table): \(error)")
                failures.append(table)
            }
        }

        if !failures.isEmpty {
            throw NSError(
                domain: "AccountDeletion",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Couldn't fully delete your data (failed: \(failures.joined(separator: ", "))). Please try again."]
            )
        }
    }

    private struct NewSession: Encodable {
        let id: String
        let user_id: String
        let technique_id: String
        let duration_minutes: Int
        let ambient_sound: String
        let bell_enabled: Bool
    }

    /// Inserts a `mind_sessions` row as the session begins. The id is
    /// generated client-side (same pattern as Remedy Reminder's inserts) so
    /// the caller has it immediately, without a select-after-insert round
    /// trip, to later link a check-in or mark the session completed.
    func startSession(userId: String, config: SessionConfig) async -> UUID? {
        let sessionId = UUID()
        let row = NewSession(
            id: sessionId.uuidString,
            user_id: userId,
            technique_id: config.techniqueId,
            duration_minutes: config.durationMinutes,
            ambient_sound: config.ambientSound.rawValue,
            bell_enabled: config.bellEnabled
        )
        do {
            try await client.from("mind_sessions").insert(row).execute()
            return sessionId
        } catch {
            print("[SupabaseService] startSession error:", error)
            return nil
        }
    }

    func completeSession(sessionId: UUID) async {
        struct Update: Encodable { let completed_at: Date }
        do {
            try await client
                .from("mind_sessions")
                .update(Update(completed_at: Date()))
                .eq("id", value: sessionId.uuidString)
                .execute()
        } catch {
            print("[SupabaseService] completeSession error:", error)
        }
    }

    private struct NewCheckIn: Encodable {
        let id: String
        let user_id: String
        let session_id: String?
        let mood: String
        let distraction_level: String?
        let note: String?
    }

    func saveCheckIn(userId: String, sessionId: UUID?, mood: String, distractionLevel: String?, note: String?) async {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let row = NewCheckIn(
            id: UUID().uuidString,
            user_id: userId,
            session_id: sessionId?.uuidString,
            mood: mood,
            distraction_level: distractionLevel,
            note: (trimmedNote?.isEmpty ?? true) ? nil : trimmedNote
        )
        do {
            try await client.from("mind_checkins").insert(row).execute()
        } catch {
            print("[SupabaseService] saveCheckIn error:", error)
        }
    }

    /// Fetches the user's most recent session, for the Home screen's
    /// "Continue" card. Returns nil for a first-time user (no fabricated
    /// "last practised" copy for a session that never happened).
    func fetchLastSession(userId: String) async -> MindSession? {
        do {
            let sessions: [MindSession] = try await client
                .from("mind_sessions")
                .select()
                .eq("user_id", value: userId)
                .order("started_at", ascending: false)
                .limit(1)
                .execute()
                .value
            return sessions.first
        } catch {
            print("[SupabaseService] fetchLastSession error:", error)
            return nil
        }
    }
}
