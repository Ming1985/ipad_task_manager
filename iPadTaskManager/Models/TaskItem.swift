import Foundation
import SwiftData

/// 任务
@Model
final class TaskItem {
    /// 任务名称
    var name: String

    /// 任务描述
    var taskDescription: String

    /// 时长（分钟）
    var durationMinutes: Int

    /// 积分奖励
    var pointsReward: Int

    /// 是否需要截图反馈
    var requiresScreenshot: Bool

    /// 指定 App 的 token（FamilyControls）
    /// 存储为 Data 因为 ApplicationToken 需要序列化
    var allowedAppTokens: Data?

    /// 创建时间
    var createdAt: Date

    /// 是否为模板
    var isTemplate: Bool

    /// 模板名称（如果是从模板创建的）
    var templateName: String?

    /// 所属计划（可选）
    @Relationship(inverse: \TaskPlan.tasks)
    var plan: TaskPlan?

    /// 关联的执行记录
    @Relationship(deleteRule: .cascade)
    var sessions: [TaskSession]

    init(
        name: String,
        taskDescription: String = "",
        durationMinutes: Int = 30,
        pointsReward: Int = 10,
        requiresScreenshot: Bool = false,
        isTemplate: Bool = false,
        templateName: String? = nil
    ) {
        self.name = name
        self.taskDescription = taskDescription
        self.durationMinutes = durationMinutes
        self.pointsReward = pointsReward
        self.requiresScreenshot = requiresScreenshot
        self.createdAt = Date()
        self.isTemplate = isTemplate
        self.templateName = templateName
        self.sessions = []
    }
}
