import SwiftUI
import SwiftData

struct PostSessionCheckInView: View {
    let session: LocalSession
    let onDone: () -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var mood: String? = nil
    @State private var distraction: String? = nil
    @State private var note: String = ""

    private let moods = ["Calm", "Neutral", "Stressed"]
    private let distractions = ["Low", "Medium", "High"]

    private var ready: Bool { mood != nil }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SESSION COMPLETE \u{00B7} \(session.actualMinutes) MIN")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(AppTheme.accent)

                        Text("How do you feel?")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 10)

                        pillRow(options: moods, selection: $mood)
                            .padding(.top, 16)

                        Text("How distracted was your mind?")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 30)

                        pillRow(options: distractions, selection: $distraction)
                            .padding(.top, 16)

                        Text("NOTE \u{00B7} OPTIONAL")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.6)
                            .foregroundColor(AppTheme.textTertiary)
                            .padding(.top, 30)

                        TextEditor(text: $note)
                            .scrollContentBackground(.hidden)
                            .frame(height: 70)
                            .padding(10)
                            .background(AppTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.control)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
                            .foregroundColor(AppTheme.textPrimary.opacity(0.85))
                            .font(.system(size: 14))
                            .padding(.top, 10)
                            .overlay(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("Anything you noticed...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 18)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.horizontal, AppTheme.Spacing.screenPadding)
                    .padding(.top, 44)
                }

                doneButton
                    .padding(.horizontal, AppTheme.Spacing.screenPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
            }
        }
        .navigationBarHidden(true)
    }

    private func pillRow(options: [String], selection: Binding<String?>) -> some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { label in
                let selected = selection.wrappedValue == label
                Text(label)
                    .font(.system(size: 13.5, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selected ? AppTheme.accent : AppTheme.pillBackground)
                    .foregroundColor(selected ? AppTheme.onAccent : AppTheme.textPrimary.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.pill)
                            .stroke(selected ? AppTheme.accent : AppTheme.pillBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { selection.wrappedValue = label }
                    }
            }
        }
    }

    private var doneButton: some View {
        Button {
            saveAndFinish()
        } label: {
            Text("Done")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(ready ? AppTheme.onAccent : AppTheme.textFaint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(ready ? AppTheme.accent : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.row))
        }
        .disabled(!ready)
    }

    private func saveAndFinish() {
        guard let mood else { return }
        session.mood = mood
        session.distractionLevel = distraction
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        session.note = trimmedNote.isEmpty ? nil : trimmedNote
        try? modelContext.save()
        onDone()
    }
}
