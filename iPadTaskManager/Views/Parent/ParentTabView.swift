import SwiftUI

/// 家长模式主界面 - TabView
struct ParentTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            // 任务管理
            ParentTaskManageView()
                .tabItem {
                    Label("任务", systemImage: "list.bullet.clipboard")
                }

            // 奖励配置
            ParentRewardConfigView()
                .tabItem {
                    Label("奖励", systemImage: "gift")
                }

            // 统计
            ParentStatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }

            // 设置
            ParentSettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .tint(AppColors.parentAccent)
    }
}

// MARK: - 任务管理视图

struct ParentTaskManageView: View {
    var body: some View {
        TabView {
            // 任务列表
            ParentTaskListView()
                .tabItem {
                    Label("任务", systemImage: "checklist")
                }

            // 计划列表
            ParentPlanListView()
                .tabItem {
                    Label("计划", systemImage: "calendar.badge.plus")
                }

            // 任务模板
            ParentTemplateListView()
                .tabItem {
                    Label("模板", systemImage: "bookmark")
                }
        }
    }
}

struct ParentRewardConfigView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("可用奖励") {
                    Text("暂无奖励配置")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("奖励配置")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("添加", systemImage: "plus") { }
                }
            }
        }
    }
}

struct ParentStatsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "暂无统计数据",
                systemImage: "chart.bar"
            )
            .navigationTitle("统计")
        }
    }
}

struct ParentSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            List {
                Section("功能") {
                    NavigationLink {
                        ScreenTimeSettingsView()
                    } label: {
                        Label("屏幕使用时间", systemImage: "hourglass")
                    }
                }

                Section("账户") {
                    Button("修改密码") {
                        showChangePassword = true
                    }
                }

                Section("数据") {
                    Button("备份到 iCloud") { }
                    Button("从 iCloud 恢复") { }
                }

                Section {
                    Button("退出家长模式") {
                        appState.switchToChildMode()
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
        }
    }
}

#Preview {
    ParentTabView()
        .environmentObject(AppState())
}
