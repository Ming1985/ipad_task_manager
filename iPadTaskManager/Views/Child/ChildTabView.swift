import SwiftUI

/// 孩子模式主界面 - TabView
struct ChildTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            // 任务列表
            ChildTaskListView()
                .tabItem {
                    Label("任务", systemImage: "checklist")
                }

            // 奖励商城
            ChildRewardShopView()
                .tabItem {
                    Label("奖励", systemImage: "gift")
                }

            // 我的
            ChildProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle")
                }
        }
        .tint(AppColors.primary)
    }
}

// MARK: - 占位视图

/// 孩子界面占位视图模板
private struct ChildPlaceholderView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let navTitle: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(navTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.childBackground)
        }
    }
}

struct ChildTaskListView: View {
    var body: some View {
        ChildPlaceholderView(
            icon: "checklist",
            iconColor: AppColors.primary,
            title: "今日任务",
            subtitle: "暂无任务",
            navTitle: "任务"
        )
    }
}

struct ChildRewardShopView: View {
    var body: some View {
        ChildPlaceholderView(
            icon: "gift",
            iconColor: AppColors.reward,
            title: "奖励商城",
            subtitle: "完成任务获得积分，兑换奖励",
            navTitle: "奖励"
        )
    }
}

struct ChildProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primary)

                Text("我的积分")
                    .font(.title2)
                Text("0")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(AppColors.reward)

                Spacer()

                // 切换到家长模式按钮
                Button {
                    appState.switchToParentMode()
                } label: {
                    Label("家长模式", systemImage: "lock.shield")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 40)
            }
            .navigationTitle("我的")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.childBackground)
        }
    }
}

#Preview {
    ChildTabView()
        .environmentObject(AppState())
}
