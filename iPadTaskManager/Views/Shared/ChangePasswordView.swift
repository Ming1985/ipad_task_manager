import SwiftUI

/// 修改密码视图
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    enum Step {
        case verifyOld
        case newPassword
        case success
    }

    @State private var currentStep: Step = .verifyOld
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                switch currentStep {
                case .verifyOld:
                    verifyOldPasswordView
                case .newPassword:
                    NewPasswordInputView(
                        newPassword: $newPassword,
                        confirmPassword: $confirmPassword,
                        showError: showError,
                        errorMessage: errorMessage,
                        buttonTitle: "确认修改",
                        onSubmit: saveNewPassword
                    )
                case .success:
                    PasswordSuccessView(
                        title: "密码修改成功",
                        subtitle: "下次请使用新密码登录",
                        buttonTitle: "完成",
                        onComplete: { dismiss() }
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if currentStep != .success {
                        Button("取消") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - 验证旧密码视图

    private var verifyOldPasswordView: some View {
        VStack(spacing: 32) {
            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary)

            Text("验证当前密码")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("请输入当前密码以验证身份")
                .foregroundStyle(.secondary)

            PasswordField(title: "", text: $oldPassword)
                .frame(maxWidth: 300)

            if showError {
                ErrorText(message: errorMessage)
            }

            Button {
                verifyOldPassword()
            } label: {
                Text("验证")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(oldPassword.count != 6)
        }
    }

    // MARK: - 逻辑方法

    private func verifyOldPassword() {
        showError = false

        if KeychainService.verifyPassword(oldPassword) {
            withAnimation { currentStep = .newPassword }
        } else {
            errorMessage = "密码不正确，请重试"
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

        guard newPassword != oldPassword else {
            errorMessage = "新密码不能与旧密码相同"
            showError = true
            return
        }

        guard KeychainService.savePassword(newPassword) else {
            errorMessage = "保存密码失败，请重试"
            showError = true
            return
        }

        withAnimation { currentStep = .success }
    }
}

#Preview {
    ChangePasswordView()
}
