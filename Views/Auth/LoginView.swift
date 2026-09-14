import SwiftUI
import Supabase
import Auth

/// Reuses Remedy Reminder's Supabase Email/OTP auth pattern — a user can
/// sign into Mind Remedy with the same credentials as Remedy Reminder if
/// they have both, or sign up fresh through the same flow. See CLAUDE.md
/// "Backend — Supabase".
struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var otpCode = ""
    @State private var step: LoginStep = .email
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    enum LoginStep { case email, otp }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Mind Remedy")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("A quiet place to practice")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                VStack(spacing: 20) {
                    if step == .email {
                        emailStep
                    } else {
                        otpStep
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(AppTheme.card)
                .cornerRadius(AppTheme.Radius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()

                Text("By continuing you agree to our Terms of Service and Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textFaint)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
    }

    var emailStep: some View {
        VStack(spacing: 16) {
            Text("Sign in or create account")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Text("Enter your email and we'll send you a code")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            ZStack(alignment: .leading) {
                if email.isEmpty {
                    Text("your@email.com")
                        .foregroundColor(.gray)
                }
                TextField("", text: $email)
                    .foregroundColor(AppTheme.onAccent)
                    .tint(AppTheme.onAccent)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(AppTheme.Radius.control)

            Button {
                Task { await sendOTP() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(AppTheme.onAccent).scaleEffect(0.8)
                    }
                    Text(isLoading ? "Sending..." : "Send code")
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.onAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.accent)
                .cornerRadius(AppTheme.Radius.control)
            }
            .disabled(email.isEmpty || isLoading)
        }
    }

    var otpStep: some View {
        VStack(spacing: 16) {
            Text("Check your email")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Text("We sent a 6-digit code to\n\(email)")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            ZStack {
                if otpCode.isEmpty {
                    Text("000000")
                        .font(.title2.monospacedDigit())
                        .foregroundColor(.gray)
                }
                TextField("", text: $otpCode)
                    .foregroundColor(AppTheme.onAccent)
                    .tint(AppTheme.onAccent)
                    .keyboardType(.numberPad)
                    .font(.title2.monospacedDigit())
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(AppTheme.Radius.control)

            Button {
                Task { await verifyOTP() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(AppTheme.onAccent).scaleEffect(0.8)
                    }
                    Text(isLoading ? "Verifying..." : "Confirm")
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.onAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.accent)
                .cornerRadius(AppTheme.Radius.control)
            }
            .disabled(otpCode.count < 6 || isLoading)

            Button {
                withAnimation { step = .email }
                otpCode = ""
                errorMessage = nil
            } label: {
                Text("Use a different email")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    func sendOTP() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await SupabaseService.shared.client.auth.signInWithOTP(
                email: email,
                shouldCreateUser: true
            )
            withAnimation { step = .otp }
        } catch {
            errorMessage = "Could not send code: \(error.localizedDescription)"
        }
    }

    func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await SupabaseService.shared.client.auth.verifyOTP(
                email: email,
                token: otpCode,
                type: .email
            )
            appState.userId = response.user.id.uuidString.lowercased()
            appState.userEmail = response.user.email ?? ""
            appState.isAuthenticated = true
        } catch {
            errorMessage = "Invalid or expired code. Please try again."
            otpCode = ""
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
