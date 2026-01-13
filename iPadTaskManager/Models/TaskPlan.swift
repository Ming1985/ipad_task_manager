import Foundation
import SwiftData

/// 任务计划（任务序列）
@Model
final class TaskPlan {
    /// 计划名称
    var name: String

    /// 包含的任务列表（有序）
    @Relationship(deleteRule: .nullify)
    var tasks: [TaskItem]

    /// 任务顺序（存储任务 ID 的顺序）
    var taskOrder: [UUID]

    /// 可用时间段开始（如 16:00）
    var availableStartTime: Date?

    /// 可用时间段结束（如 18:00）
    var availableEndTime: Date?

    /// 完成整个计划的额外奖励积分
    var bonusPoints: Int

    /// 任务间休息时间（秒）
    var breakDurationSeconds: Int

    /// 创建时间
    var createdAt: Date

    /// 计算总时长（分钟）
    var totalDurationMinutes: Int {
        tasks.reduce(0) { $0 + $1.durationMinutes }
    }

    /// 计算总积分（包括额外奖励）
    var totalPoints: Int {
        tasks.reduce(0) { $0 + $1.pointsReward } + bonusPoints
    }

    init(
        name: String,
        bonusPoints: Int = 0,
        breakDurationSeconds: Int = 0
    ) {
        self.name = name
        self.tasks = []
        self.taskOrder = []
        self.bonusPoints = bonusPoints
        self.breakDurationSeconds = breakDurationSeconds
        self.createdAt = Date()
    }
}
