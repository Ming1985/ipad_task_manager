import Foundation
import SwiftData

/// 任务计划（任务序列）
@Model
final class TaskPlan {
    /// 计划名称
    var name: String

    /// 包含的任务列表（有序）
    /// 注意：@Relationship 会自动去重，不支持重复任务
    /// 使用 taskOrder 存储完整顺序（包括重复项）
    @Relationship(deleteRule: .nullify)
    var tasks: [TaskItem]

    /// 任务顺序（存储为 JSON Data，因为 SwiftData 不支持 [UUID]）
    var taskOrderData: Data?

    /// 计划模式: "fixed" 固定时间段, "flexible" 随时可开始
    var mode: String

    /// 可用时间段开始（如 16:00）
    var availableStartTime: Date?

    /// 可用时间段结束（如 18:00）
    var availableEndTime: Date?

    /// 完成整个计划的额外奖励积分
    var bonusPoints: Int

    /// 任务间休息时间（秒）
    var breakDurationSeconds: Int

    /// 任务时长覆盖配置（JSON Data）
    /// 格式: { "uuid-string": durationMinutes }
    var taskDurationOverridesData: Data?

    /// 创建时间
    var createdAt: Date

    /// 是否为固定时间模式
    var isFixedMode: Bool { mode == "fixed" }

    /// 计算总时长（分钟），考虑时长覆盖和重复任务
    var totalDurationMinutes: Int {
        orderedTasks.reduce(0) { total, task in
            total + effectiveDuration(for: task)
        }
    }

    /// 计算总积分（包括额外奖励）
    var totalPoints: Int {
        orderedTasks.reduce(0) { $0 + $1.pointsReward } + bonusPoints
    }

    /// 获取/设置任务顺序
    var taskOrder: [UUID] {
        get {
            guard let data = taskOrderData else { return [] }
            return (try? JSONDecoder().decode([UUID].self, from: data)) ?? []
        }
        set {
            taskOrderData = try? JSONEncoder().encode(newValue)
        }
    }

    /// 获取/设置任务时长覆盖
    var taskDurationOverrides: [String: Int] {
        get {
            guard let data = taskDurationOverridesData else { return [:] }
            return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        }
        set {
            taskDurationOverridesData = try? JSONEncoder().encode(newValue)
        }
    }

    /// 获取任务在此计划中的有效时长
    func effectiveDuration(for task: TaskItem) -> Int {
        if let override = taskDurationOverrides[task.taskId.uuidString] {
            return override
        }
        return task.durationMinutes
    }

    /// 获取完整的任务顺序列表（包括重复，向后兼容空 taskOrder）
    var orderedTasks: [TaskItem] {
        let taskDict = Dictionary(uniqueKeysWithValues: tasks.map { ($0.taskId, $0) })
        let ordered = taskOrder.compactMap { taskDict[$0] }
        return ordered.isEmpty ? tasks : ordered
    }

    /// 设置任务在此计划中的时长覆盖
    func setDurationOverride(for task: TaskItem, duration: Int) {
        var overrides = taskDurationOverrides
        overrides[task.taskId.uuidString] = duration
        taskDurationOverrides = overrides
    }

    init(
        name: String,
        mode: String = "flexible",
        bonusPoints: Int = 0,
        breakDurationSeconds: Int = 0
    ) {
        self.name = name
        self.mode = mode
        self.tasks = []
        self.bonusPoints = bonusPoints
        self.breakDurationSeconds = breakDurationSeconds
        self.createdAt = Date()
    }
}
