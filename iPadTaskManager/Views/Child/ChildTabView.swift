import SwiftUI
import SwiftData

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

// MARK: - 子视图

struct ChildTaskListView: View {
    @Query private var settingsArray: [AppSettings]
    @Query private var plans: [TaskPlan]

    private var settings: AppSettings? { settingsArray.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 头部：日期问候 + 积分
                    ChildHeaderView(points: settings?.currentPoints ?? 0)

                    // 任务/计划列表
                    if plans.isEmpty {
                        ChildEmptyStateView()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(plans) { plan in
                                ChildPlanCard(plan: plan)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(AppColors.childBackground)
            .navigationTitle("今日任务")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 孩子界面组件

/// 头部视图：日期问候 + 积分
struct ChildHeaderView: View {
    let points: Int

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "早上好！" }
        if hour < 14 { return "中午好！" }
        if hour < 18 { return "下午好！" }
        return "晚上好！"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(dateString)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 积分显示
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("\(points)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AppColors.reward)
                }
                Text("积分")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.childCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

/// 空状态视图
struct ChildEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("太棒了！")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("暂时没有任务\n好好休息一下吧")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

/// 计划卡片
struct ChildPlanCard: View {
    let plan: TaskPlan
    @State private var showExecution = false

    private var timeRangeText: String? {
        guard plan.isFixedMode,
              let start = plan.availableStartTime,
              let end = plan.availableEndTime else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 计划标题
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    // 固定时间段显示
                    if let timeRange = timeRangeText {
                        Label(timeRange, systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // 总积分
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("+\(plan.totalPoints)")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.reward)
                }
            }

            Divider()

            // 任务列表
            ForEach(plan.tasks) { task in
                ChildTaskRow(task: task, planDuration: plan.effectiveDuration(for: task))
            }

            // 开始按钮
            Button {
                showExecution = true
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("开始任务")
                        .fontWeight(.semibold)
                }
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(plan.tasks.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.childCardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .fullScreenCover(isPresented: $showExecution) {
            PlanExecutionView(plan: plan)
        }
    }
}

/// 任务行（计划内的单个任务）
struct ChildTaskRow: View {
    let task: TaskItem
    let planDuration: Int

    var body: some View {
        HStack(spacing: 12) {
            // 任务类型图标
            Image(systemName: task.isRestTask ? "gamecontroller.fill" : "book.fill")
                .font(.title3)
                .foregroundStyle(task.isRestTask ? .green : .blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(task.isRestTask ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    // 时长
                    Label("\(planDuration)分钟", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // 积分
                    Label("+\(task.pointsReward)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(AppColors.reward)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ChildRewardShopView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "gift")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.reward)
                Text("奖励商城")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("完成任务获得积分，兑换奖励")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("奖励")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.childBackground)
        }
    }
}

struct ChildProfileView: View {
    @EnvironmentObject private var appState: AppState
    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings? { settingsArray.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // 头像
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(AppColors.primary)
                            .padding(.top, 20)

                        // 积分卡片
                        VStack(spacing: 8) {
                            Text("我的积分")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundStyle(.yellow)
                                Text("\(settings?.currentPoints ?? 0)")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundStyle(AppColors.reward)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppColors.childCardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        )
                        .padding(.horizontal)

                        // 连续完成
                        if let streak = settings?.streakCount, streak > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("连续完成 \(streak) 天")
                                    .fontWeight(.medium)
                            }
                            .font(.title3)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }

                Spacer()

                // 切换到家长模式按钮 - 固定在底部
                Button {
                    appState.switchToParentMode()
                } label: {
                    Label("家长模式", systemImage: "lock.shield")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 30)
            }
            .navigationTitle("我的")
            .background(AppColors.childBackground)
        }
    }
}

#Preview {
    ChildTabView()
        .environmentObject(AppState())
}
