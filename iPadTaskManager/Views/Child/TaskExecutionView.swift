import SwiftUI
import SwiftData
import UIKit
import FamilyControls

/// 任务执行视图
struct TaskExecutionView: View {
    let taskItem: TaskItem
    let durationMinutes: Int
    let onComplete: (Int) -> Void  // 完成回调，传入获得的积分
    let onAbandon: () -> Void

    @State private var remainingSeconds: Int
    @State private var isPaused = false
    @State private var showAbandonAlert = false
    @State private var showCompleteEarlyAlert = false
    @State private var timer: Timer?
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    // 后台处理
    @State private var backgroundDate: Date?

    init(
        taskItem: TaskItem,
        durationMinutes: Int,
        onComplete: @escaping (Int) -> Void,
        onAbandon: @escaping () -> Void
    ) {
        self.taskItem = taskItem
        self.durationMinutes = durationMinutes
        self.onComplete = onComplete
        self.onAbandon = onAbandon
        self._remainingSeconds = State(initialValue: durationMinutes * 60)
    }

    private var progress: Double {
        let total = Double(durationMinutes * 60)
        let remaining = Double(remainingSeconds)
        return (total - remaining) / total
    }

    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            // 任务信息（固定高度，避免描述影响进度环位置）
            VStack(spacing: 12) {
                Image(systemName: taskItem.isRestTask ? "gamecontroller.fill" : "book.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(taskItem.isRestTask ? .green : .blue)

                Text(taskItem.name)
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(taskItem.taskDescription)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(taskItem.taskDescription.isEmpty ? 0 : 1)
            }
            .frame(height: 180)

            // 进度环 + 倒计时
            ZStack {
                // 背景圆
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 28)
                    .frame(width: 320, height: 320)

                // 进度环
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        taskItem.isRestTask ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 28, lineCap: .round)
                    )
                    .frame(width: 320, height: 320)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)

                // 时间显示
                VStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 80, weight: .bold, design: .monospaced))

                    Text("剩余时间")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            // 暂停状态提示
            if isPaused {
                HStack(spacing: 12) {
                    Image(systemName: "pause.circle.fill")
                        .foregroundStyle(.orange)
                    Text("已暂停")
                        .fontWeight(.medium)
                }
                .font(.title2)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                )
            }

            Spacer()

            // 提前完成按钮
            Button {
                showCompleteEarlyAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("我已完成")
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: 300)
                .padding(.vertical, 16)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // 控制按钮
            HStack(spacing: 60) {
                // 放弃按钮
                Button {
                    showAbandonAlert = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.red)
                        Text("放弃")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                    }
                }

                // 暂停/继续按钮
                Button {
                    isPaused.toggle()
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(isPaused ? .green : .orange)
                        Text(isPaused ? "继续" : "暂停")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(isPaused ? .green : .orange)
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.childBackground)
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            handleBackgroundEntry()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            handleForegroundEntry()
        }
        .alert("确定放弃任务？", isPresented: $showAbandonAlert) {
            Button("取消", role: .cancel) { }
            Button("放弃", role: .destructive) {
                stopTimer()
                onAbandon()
            }
        } message: {
            Text("放弃后本次任务不会获得积分")
        }
        .alert("确认完成任务？", isPresented: $showCompleteEarlyAlert) {
            Button("取消", role: .cancel) { }
            Button("已完成") {
                completeTask()
            }
        } message: {
            Text("确认已完成任务目标，将获得全部积分奖励")
        }
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused && remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds == 0 {
                    completeTask()
                }
            }
        }

        // 开始 App 屏蔽（仅学习任务）
        if taskItem.taskType == "study", let appData = taskItem.allowedAppTokens {
            do {
                let allowedApps = try JSONDecoder().decode(FamilyActivitySelection.self, from: appData)
                screenTimeManager.startTaskShielding(allowedApps: allowedApps)
            } catch {
                print("Failed to decode app selection: \(error)")
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        // 停止 App 屏蔽
        screenTimeManager.stopTaskShielding()
    }

    private func completeTask() {
        stopTimer()
        onComplete(taskItem.pointsReward)
    }

    // MARK: - Background Handling

    private func handleBackgroundEntry() {
        if !isPaused {
            backgroundDate = Date()
        }
    }

    private func handleForegroundEntry() {
        guard let bgDate = backgroundDate, !isPaused else {
            backgroundDate = nil
            return
        }

        let elapsed = Int(Date().timeIntervalSince(bgDate))
        remainingSeconds = max(0, remainingSeconds - elapsed)
        backgroundDate = nil

        if remainingSeconds == 0 {
            completeTask()
        }
    }
}

// MARK: - 计划执行视图

/// 计划执行视图（序列执行多个任务）
struct PlanExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settingsArray: [AppSettings]

    let plan: TaskPlan

    @State private var currentTaskIndex = 0
    @State private var isCompleted = false
    @State private var earnedPoints = 0
    @State private var session: TaskSession?

    private var settings: AppSettings? { settingsArray.first }

    private var currentTask: TaskItem? {
        guard currentTaskIndex < plan.orderedTasks.count else { return nil }
        return plan.orderedTasks[currentTaskIndex]
    }

    private var currentDuration: Int {
        guard let task = currentTask else { return 0 }
        return plan.effectiveDuration(for: task)
    }

    var body: some View {
        NavigationStack {
            if isCompleted {
                // 完成页面
                PlanCompletedView(
                    planName: plan.name,
                    totalPoints: earnedPoints,
                    onDismiss: { dismiss() }
                )
            } else if let task = currentTask {
                VStack(spacing: 0) {
                    // 进度指示器
                    ProgressHeader(
                        current: currentTaskIndex + 1,
                        total: plan.orderedTasks.count,
                        planName: plan.name
                    )

                    // 任务执行
                    TaskExecutionView(
                        taskItem: task,
                        durationMinutes: currentDuration,
                        onComplete: { points in
                            handleTaskComplete(points: points)
                        },
                        onAbandon: {
                            handleTaskAbandon()
                        }
                    )
                    .id(currentTaskIndex)  // 强制任务切换时重新创建视图
                }
            } else {
                // 无任务
                ContentUnavailableView(
                    "计划无任务",
                    systemImage: "exclamationmark.triangle",
                    description: Text("请先在计划中添加任务")
                )
            }
        }
        .interactiveDismissDisabled()  // 防止滑动关闭
        .onAppear(perform: createSession)
    }

    private func createSession() {
        let newSession = TaskSession(plan: plan, planTaskIndex: 0)
        newSession.start()
        modelContext.insert(newSession)
        session = newSession
    }

    private func handleTaskComplete(points: Int) {
        earnedPoints += points

        // 更新积分
        if let settings = settings {
            settings.currentPoints += points
            try? modelContext.save()
        }

        // 检查是否还有下一个任务
        if currentTaskIndex + 1 < plan.orderedTasks.count {
            currentTaskIndex += 1
            session?.planTaskIndex = currentTaskIndex
        } else {
            // 计划完成，加上额外奖励
            earnedPoints += plan.bonusPoints
            if let settings = settings {
                settings.currentPoints += plan.bonusPoints
                try? modelContext.save()
            }
            session?.complete(points: earnedPoints)
            isCompleted = true
        }
    }

    private func handleTaskAbandon() {
        session?.abandon()
        dismiss()
    }
}

// MARK: - 进度头部

private struct ProgressHeader: View {
    let current: Int
    let total: Int
    let planName: String

    var body: some View {
        VStack(spacing: 8) {
            Text(planName)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < current ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }

            Text("任务 \(current) / \(total)")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.childCardBackground)
    }
}

// MARK: - 计划完成页面

private struct PlanCompletedView: View {
    let planName: String
    let totalPoints: Int
    let onDismiss: () -> Void

    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // 完成图标
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(.green)
                .scaleEffect(showConfetti ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)

            Text("太棒了！")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\"\(planName)\" 完成！")
                .font(.title2)
                .foregroundStyle(.secondary)

            // 积分显示
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                Text("+\(totalPoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(AppColors.reward)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.childCardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            )

            Spacer()

            // 返回按钮
            Button {
                onDismiss()
            } label: {
                Text("返回")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(AppColors.childBackground)
        .onAppear {
            showConfetti = true
        }
    }
}

#Preview {
    let taskItem = TaskItem(
        name: "语文作业",
        taskDescription: "完成今天的语文练习",
        durationMinutes: 1,
        pointsReward: 10
    )

    TaskExecutionView(
        taskItem: taskItem,
        durationMinutes: 1,
        onComplete: { _ in },
        onAbandon: { }
    )
}
