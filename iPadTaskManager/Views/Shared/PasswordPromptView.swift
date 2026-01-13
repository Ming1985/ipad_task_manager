import SwiftUI

/// 密码验证弹窗
struct PasswordPromptView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var errorCount = 0
    @State private var isLocked = false
    @State private var lockEndTime: Date?
    @State private var showError = false

    private let maxAttempts = 5
    private let lockDuration: TimeInterval = 300 // 5 分钟

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // 图标
                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isLocked ? .red : AppColors.primary)

                if isLocked, let endTime = lockEndTime {
                    // 锁定状态
                    VStack(spacing: 16) {
                        Text("密码已锁定")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("请在 \(timeRemaining(until: endTime)) 后重试")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 正常输入
                    VStack(spacing: 24) {
                        Text("输入管理员密码")
                            .font(.title2)
                            .fontWeight(.semibold)

                        PasswordField(title: "", text: $password)
                            .frame(maxWidth: 300)

                        if showError {
                            Text("密码错误，还剩 \(maxAttempts - errorCount) 次机会")
                                .foregroundStyle(.red)
                        }

                        Button {
                            verifyPassword()
                        } label: {
                            Text("确认")
                                .font(.headline)
                                .frame(maxWidth: 200)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(password.count != 6)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("验证密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func verifyPassword() {
        // TODO: 从 Keychain 读取并验证密码
        // 临时：使用固定密码 123456 测试
        let correctPassword = "123456"

        if password == correctPassword {
            appState.onPasswordVerified()
            dismiss()
        } else {
            errorCount += 1
            showError = true
            password = ""

            if errorCount >= maxAttempts {
                isLocked = true
                lockEndTime = Date().addingTimeInterval(lockDuration)

                // 5 分钟后自动解锁
                DispatchQueue.main.asyncAfter(deadline: .now() + lockDuration) {
                    isLocked = false
                    errorCount = 0
                    lockEndTime = nil
                }
            }
        }
    }

    private func timeRemaining(until date: Date) -> String {
        let remaining = max(0, date.timeIntervalSinceNow)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PasswordPromptView()
        .environmentObject(AppState())
}
