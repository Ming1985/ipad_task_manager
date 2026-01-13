import SwiftUI

/// 首次启动：设置管理员密码
struct SetupPasswordView: View {
    @EnvironmentObject private var appState: AppState
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // 图标和标题
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primary)

                Text("设置管理员密码")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("请设置 6 位数字密码，用于进入家长模式")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 密码输入
            VStack(spacing: 24) {
                PasswordField(title: "输入密码", text: $password)
                PasswordField(title: "确认密码", text: $confirmPassword)
            }
            .frame(maxWidth: 400)

            // 错误提示
            if showError {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.callout)
            }

            // 确认按钮
            Button {
                validateAndSave()
            } label: {
                Text("确认设置")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(password.count != 6 || confirmPassword.count != 6)

            Spacer()
        }
        .padding()
        .background(AppColors.childBackground)
    }

    private func validateAndSave() {
        // 验证密码格式
        guard password.count == 6, password.allSatisfy({ $0.isNumber }) else {
            errorMessage = "密码必须是 6 位数字"
            showError = true
            return
        }

        // 验证两次输入一致
        guard password == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            showError = true
            return
        }

        // TODO: 保存密码到 Keychain
        appState.isPasswordSet = true
    }
}

/// 密码输入框组件
struct PasswordField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < text.count ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                // 隐藏的输入框
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .opacity(0.01)
                    .onChange(of: text) { newValue in
                        // 限制为 6 位数字
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 6 {
                            text = filtered
                        } else {
                            text = String(filtered.prefix(6))
                        }
                    }
            }
        }
    }
}

#Preview {
    SetupPasswordView()
        .environmentObject(AppState())
}
