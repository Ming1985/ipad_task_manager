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

// MARK: - 占位视图

struct ParentTaskManageView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("任务") {
                    Text("暂无任务")
                        .foregroundStyle(.secondary)
                }
                Section("计划") {
                    Text("暂无计划")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("任务管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("新建任务", systemImage: "plus") { }
                        Button("新建计划", systemImage: "calendar.badge.plus") { }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
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

    var body: some View {
        NavigationStack {
            List {
                Section("账户") {
                    Button("修改密码") { }
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
        }
    }
}

#Preview {
    ParentTabView()
        .environmentObject(AppState())
}
