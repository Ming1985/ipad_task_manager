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
    @State private var showResetOption = false
    @State private var remainingTime = ""

    private let maxAttempts = 5
    private let lockDuration: TimeInterval = 300 // 5 分钟

    // 定时器更新剩余时间
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // 图标
                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isLocked ? .red : AppColors.primary)

                if isLocked {
                    lockedView
                } else {
                    inputView
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
            .onAppear {
                loadLockState()
            }
            .onReceive(timer) { _ in
                updateRemainingTime()
            }
        }
    }

    // MARK: - 锁定状态视图

    private var lockedView: some View {
        VStack(spacing: 16) {
            Text("密码已锁定")
                .font(.title)
                .fontWeight(.bold)

            Text("请在 \(remainingTime) 后重试")
                .font(.title3)
                .foregroundStyle(.secondary)

            // 忘记密码选项
            Button("忘记密码？") {
                showResetOption = true
            }
            .foregroundStyle(AppColors.primary)
            .padding(.top, 20)
        }
        .sheet(isPresented: $showResetOption) {
            PasswordResetView()
        }
    }

    // MARK: - 输入视图

    private var inputView: some View {
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

            // 忘记密码选项
            if errorCount >= 2 {
                Button("忘记密码？") {
                    showResetOption = true
                }
                .foregroundStyle(AppColors.primary)
            }
        }
        .sheet(isPresented: $showResetOption) {
            PasswordResetView()
        }
    }

    // MARK: - 逻辑方法

    private func loadLockState() {
        // 从 Keychain 加载锁定状态
        if let endTime = KeychainService.getLockEndTime() {
            lockEndTime = endTime
            isLocked = true
            updateRemainingTime()
        }
        errorCount = KeychainService.getFailedAttempts()
    }

    private func updateRemainingTime() {
        guard let endTime = lockEndTime else {
            if isLocked {
                // 锁定已解除
                isLocked = false
                errorCount = 0
                KeychainService.clearLockState()
            }
            return
        }

        let remaining = endTime.timeIntervalSinceNow
        if remaining <= 0 {
            // 锁定结束
            isLocked = false
            lockEndTime = nil
            errorCount = 0
            KeychainService.clearLockState()
        } else {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            remainingTime = String(format: "%d:%02d", minutes, seconds)
        }
    }

    private func verifyPassword() {
        if KeychainService.verifyPassword(password) {
            // 验证成功
            KeychainService.clearLockState()
            appState.onPasswordVerified()
            dismiss()
        } else {
            // 验证失败
            errorCount += 1
            showError = true
            password = ""

            // 保存失败次数
            KeychainService.saveFailedAttempts(errorCount)

            if errorCount >= maxAttempts {
                // 锁定
                isLocked = true
                let endTime = Date().addingTimeInterval(lockDuration)
                lockEndTime = endTime
                KeychainService.saveLockEndTime(endTime)
            }
        }
    }
}

#Preview {
    PasswordPromptView()
        .environmentObject(AppState())
}
