import SwiftUI

/// 密码重置视图（通过安全问题）
struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    enum Step {
        case verifyAnswer
        case newPassword
        case success
    }

    @State private var currentStep: Step = .verifyAnswer
    @State private var securityQuestion = ""
    @State private var answer = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                switch currentStep {
                case .verifyAnswer:
                    verifyAnswerView
                case .newPassword:
                    NewPasswordInputView(
                        newPassword: $newPassword,
                        confirmPassword: $confirmPassword,
                        showError: showError,
                        errorMessage: errorMessage,
                        buttonTitle: "确认重置",
                        onSubmit: saveNewPassword
                    )
                case .success:
                    PasswordSuccessView(
                        title: "密码重置成功",
                        subtitle: "请使用新密码登录",
                        buttonTitle: "完成",
                        onComplete: { dismiss() }
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle("重置密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if currentStep != .success {
                        Button("取消") { dismiss() }
                    }
                }
            }
            .onAppear {
                securityQuestion = KeychainService.getSecurityQuestion() ?? "未设置安全问题"
            }
        }
    }

    // MARK: - 验证安全问题视图

    private var verifyAnswerView: some View {
        VStack(spacing: 32) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary)

            Text("回答安全问题")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                Text("安全问题")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(securityQuestion)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("您的答案")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("输入答案", text: $answer)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxWidth: 400)

            if showError {
                ErrorText(message: errorMessage)
            }

            Button {
                verifySecurityAnswer()
            } label: {
                Text("验证")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(answer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - 逻辑方法

    private func verifySecurityAnswer() {
        showError = false

        if KeychainService.verifySecurityAnswer(answer) {
            withAnimation { currentStep = .newPassword }
        } else {
            errorMessage = "答案不正确，请重试"
            showError = true
        }
    }

    private func saveNewPassword() {
        showError = false

        if let error = PasswordValidation.validateNewPassword(newPassword, confirm: confirmPassword) {
            errorMessage = error
            showError = true
            return
        }

        guard KeychainService.savePassword(newPassword) else {
            errorMessage = "保存密码失败，请重试"
            showError = true
            return
        }

        KeychainService.clearLockState()
        withAnimation { currentStep = .success }
    }
}

#Preview {
    PasswordResetView()
        .environmentObject(AppState())
}
