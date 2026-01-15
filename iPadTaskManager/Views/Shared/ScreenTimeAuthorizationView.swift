import SwiftUI
import FamilyControls

/// Screen Time 授权请求视图
struct ScreenTimeAuthorizationView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isRequesting = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // 图标
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)

            // 标题
            Text("启用屏幕使用时间")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 说明
            VStack(spacing: 12) {
                FeatureRow(icon: "lock.shield", text: "任务期间自动屏蔽其他 App")
                FeatureRow(icon: "checkmark.circle", text: "完成任务后自动解锁")
                FeatureRow(icon: "star", text: "帮助孩子专注学习")
            }
            .padding(.horizontal, 40)

            Spacer()

            // 状态提示
            statusView

            // 操作按钮
            VStack(spacing: 16) {
                if screenTimeManager.authorizationStatus != .approved {
                    Button {
                        requestAuthorization()
                    } label: {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "checkmark.shield")
                            }
                            Text("授权使用")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isRequesting)

                    Button {
                        dismiss()
                    } label: {
                        Text("稍后设置")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("完成")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .alert("授权失败", isPresented: $showError) {
            Button("确定", role: .cancel) { }
            Button("打开设置") {
                openSettings()
            }
        } message: {
            Text("请在「设置 > 屏幕使用时间」中允许此 App 访问")
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch screenTimeManager.authorizationStatus {
        case .notDetermined:
            EmptyView()
        case .approved:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("已授权")
                    .fontWeight(.medium)
            }
            .font(.title3)
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        case .denied:
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("授权被拒绝")
                    .fontWeight(.medium)
            }
            .font(.title3)
            .padding()
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func requestAuthorization() {
        isRequesting = true
        Task {
            let success = await screenTimeManager.requestAuthorization()
            isRequesting = false
            if !success && screenTimeManager.authorizationStatus == .denied {
                showError = true
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    ScreenTimeAuthorizationView()
}
