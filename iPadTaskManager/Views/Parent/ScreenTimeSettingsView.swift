import SwiftUI
import FamilyControls

/// 屏幕使用时间设置视图
struct ScreenTimeSettingsView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showAppPicker = false
    @State private var showAuthorizationSheet = false

    var body: some View {
        NavigationStack {
            List {
                // 授权状态
                Section {
                    authorizationStatusRow
                }

                // 永久屏蔽设置
                if screenTimeManager.authorizationStatus == .approved {
                    Section {
                        Button {
                            showAppPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "app.badge.checkmark")
                                    .foregroundStyle(.red)
                                Text("选择永久屏蔽的 App")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        if !screenTimeManager.permanentlyBlockedApps.applicationTokens.isEmpty {
                            Text("已屏蔽 \(screenTimeManager.permanentlyBlockedApps.applicationTokens.count) 个应用")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("永久屏蔽列表")
                    } footer: {
                        Text("这些 App 将始终被屏蔽，无论是否在任务期间")
                    }

                    // 清除所有屏蔽按钮
                    Section {
                        Button(role: .destructive) {
                            clearAllShielding()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("清除所有屏蔽")
                            }
                        }
                    } footer: {
                        Text("紧急情况下使用，将移除所有 App 屏蔽")
                    }
                }
            }
            .navigationTitle("屏幕使用时间")
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $screenTimeManager.permanentlyBlockedApps
            )
            .sheet(isPresented: $showAuthorizationSheet) {
                ScreenTimeAuthorizationView()
            }
            .onChange(of: screenTimeManager.permanentlyBlockedApps) { _, _ in
                screenTimeManager.savePermanentBlockedApps()
                screenTimeManager.applyPermanentBlocking()
            }
        }
    }

    @ViewBuilder
    private var authorizationStatusRow: some View {
        switch screenTimeManager.authorizationStatus {
        case .notDetermined, .denied:
            Button {
                showAuthorizationSheet = true
            } label: {
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("需要授权")
                            .foregroundStyle(.primary)
                        Text("点击授权「屏幕使用时间」功能")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        case .approved:
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("已授权")
                    Text("可管理 App 屏蔽设置")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func clearAllShielding() {
        screenTimeManager.clearAllShielding()
        screenTimeManager.permanentlyBlockedApps = FamilyActivitySelection()
        screenTimeManager.savePermanentBlockedApps()
    }
}

#Preview {
    ScreenTimeSettingsView()
}
