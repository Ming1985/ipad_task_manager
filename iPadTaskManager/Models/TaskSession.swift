import Foundation
import SwiftData

/// 任务执行记录
@Model
final class TaskSession {
    /// 执行状态
    enum Status: String, Codable {
        case pending = "pending"         // 待开始
        case inProgress = "in_progress"  // 进行中
        case completed = "completed"     // 已完成
        case abandoned = "abandoned"     // 已放弃
        case paused = "paused"           // 已暂停
    }

    /// 关联的任务
    @Relationship
    var task: TaskItem?

    /// 关联的计划（如果是计划中的任务）
    @Relationship
    var plan: TaskPlan?

    /// 计划中的任务索引
    var planTaskIndex: Int?

    /// 状态
    var statusRaw: String

    var status: Status {
        get { Status(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// 开始时间
    var startedAt: Date?

    /// 结束时间
    var endedAt: Date?

    /// 实际用时（秒）
    var actualDurationSeconds: Int

    /// 获得的积分
    var pointsEarned: Int

    /// 活跃度评分（0-100）
    var activityScore: Int

    /// 关联的截图
    @Relationship(deleteRule: .cascade)
    var screenshots: [Screenshot]

    /// 关联的 App 使用日志
    @Relationship(deleteRule: .cascade)
    var usageLogs: [AppUsageLog]

    /// 创建时间
    var createdAt: Date

    init(task: TaskItem? = nil, plan: TaskPlan? = nil, planTaskIndex: Int? = nil) {
        self.task = task
        self.plan = plan
        self.planTaskIndex = planTaskIndex
        self.statusRaw = Status.pending.rawValue
        self.actualDurationSeconds = 0
        self.pointsEarned = 0
        self.activityScore = 0
        self.screenshots = []
        self.usageLogs = []
        self.createdAt = Date()
    }

    /// 开始任务
    func start() {
        status = .inProgress
        startedAt = Date()
    }

    /// 结束任务（内部方法）
    private func end(with newStatus: Status) {
        status = newStatus
        endedAt = Date()
        if let start = startedAt {
            actualDurationSeconds = Int(Date().timeIntervalSince(start))
        }
    }

    /// 完成任务
    func complete(points: Int) {
        end(with: .completed)
        pointsEarned = points
    }

    /// 放弃任务
    func abandon() {
        end(with: .abandoned)
    }
}
