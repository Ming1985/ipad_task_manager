import SwiftUI

// MARK: - 密码验证工具

enum PasswordValidation {
    /// 验证密码格式（6位数字）
    static func validateFormat(_ password: String) -> String? {
        guard password.count == 6, password.allSatisfy({ $0.isNumber }) else {
            return "密码必须是 6 位数字"
        }
        return nil
    }

    /// 验证两次密码一致
    static func validateMatch(_ password: String, _ confirm: String) -> String? {
        guard password == confirm else {
            return "两次输入的密码不一致"
        }
        return nil
    }

    /// 完整验证新密码（格式 + 一致性）
    static func validateNewPassword(_ password: String, confirm: String) -> String? {
        if let error = validateFormat(password) {
            return error
        }
        return validateMatch(password, confirm)
    }
}

// MARK: - 错误提示组件

struct ErrorText: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundStyle(.red)
            .font(.callout)
    }
}

// MARK: - 成功视图组件

struct PasswordSuccessView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .foregroundStyle(.secondary)

            Button {
                onComplete()
            } label: {
                Text(buttonTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - 新密码输入视图组件

struct NewPasswordInputView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    let showError: Bool
    let errorMessage: String
    let buttonTitle: String
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary)

            Text("设置新密码")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 24) {
                PasswordField(title: "新密码", text: $newPassword)
                PasswordField(title: "确认密码", text: $confirmPassword)
            }
            .frame(maxWidth: 400)

            if showError {
                ErrorText(message: errorMessage)
            }

            Button {
                onSubmit()
            } label: {
                Text(buttonTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(newPassword.count != 6 || confirmPassword.count != 6)
        }
    }
}
