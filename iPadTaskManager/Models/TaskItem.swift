import Foundation
import SwiftData

/// 任务
@Model
final class TaskItem {
    /// 唯一标识符（用于时长覆盖等场景）
    var taskId: UUID

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

    /// 任务类型: "study" 学习任务, "rest" 休息/游戏
    var taskType: String

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

    /// 是否为休息任务
    var isRestTask: Bool { taskType == "rest" }

    init(
        name: String,
        taskDescription: String = "",
        durationMinutes: Int = 30,
        pointsReward: Int = 10,
        requiresScreenshot: Bool = false,
        taskType: String = "study",
        isTemplate: Bool = false,
        templateName: String? = nil
    ) {
        self.taskId = UUID()
        self.name = name
        self.taskDescription = taskDescription
        self.durationMinutes = durationMinutes
        self.pointsReward = pointsReward
        self.requiresScreenshot = requiresScreenshot
        self.taskType = taskType
        self.createdAt = Date()
        self.isTemplate = isTemplate
        self.templateName = templateName
        self.sessions = []
    }
}

// MARK: - 任务模板

/// 任务模板数据结构
struct TaskTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let durationMinutes: Int
    let pointsReward: Int
    let requiresScreenshot: Bool
    let category: String

    /// 从模板创建 TaskItem
    func createTask() -> TaskItem {
        return TaskItem(
            name: name,
            taskDescription: description,
            durationMinutes: durationMinutes,
            pointsReward: pointsReward,
            requiresScreenshot: requiresScreenshot,
            isTemplate: false,
            templateName: name
        )
    }
}

/// 预设任务模板
enum PresetTemplates {
    /// 所有预设模板
    static let all: [TaskTemplate] = [
        // 学习类
        TaskTemplate(
            name: "阅读任务",
            description: "阅读课外书或绘本，培养阅读习惯",
            durationMinutes: 30,
            pointsReward: 20,
            requiresScreenshot: true,
            category: "学习"
        ),
        TaskTemplate(
            name: "数学练习",
            description: "完成数学作业或练习题",
            durationMinutes: 45,
            pointsReward: 25,
            requiresScreenshot: true,
            category: "学习"
        ),
        TaskTemplate(
            name: "英语学习",
            description: "英语阅读、听力或单词练习",
            durationMinutes: 40,
            pointsReward: 20,
            requiresScreenshot: true,
            category: "学习"
        ),
        TaskTemplate(
            name: "语文学习",
            description: "语文阅读理解或写作练习",
            durationMinutes: 40,
            pointsReward: 20,
            requiresScreenshot: true,
            category: "学习"
        ),

        // 才艺类
        TaskTemplate(
            name: "钢琴练习",
            description: "练习钢琴曲目或基础练习",
            durationMinutes: 30,
            pointsReward: 15,
            requiresScreenshot: false,
            category: "才艺"
        ),
        TaskTemplate(
            name: "绘画创作",
            description: "绘画、涂色或手工创作",
            durationMinutes: 60,
            pointsReward: 30,
            requiresScreenshot: true,
            category: "才艺"
        ),
        TaskTemplate(
            name: "乐器练习",
            description: "吉他、小提琴等乐器练习",
            durationMinutes: 30,
            pointsReward: 15,
            requiresScreenshot: false,
            category: "才艺"
        ),

        // 运动类
        TaskTemplate(
            name: "户外运动",
            description: "跑步、骑车或其他户外活动",
            durationMinutes: 30,
            pointsReward: 15,
            requiresScreenshot: false,
            category: "运动"
        ),
        TaskTemplate(
            name: "体育锻炼",
            description: "跳绳、做操或室内运动",
            durationMinutes: 20,
            pointsReward: 10,
            requiresScreenshot: false,
            category: "运动"
        ),

        // 生活类
        TaskTemplate(
            name: "整理房间",
            description: "整理书桌、玩具或房间",
            durationMinutes: 15,
            pointsReward: 10,
            requiresScreenshot: false,
            category: "生活"
        ),
        TaskTemplate(
            name: "帮助家务",
            description: "帮助做家务或照顾弟妹",
            durationMinutes: 20,
            pointsReward: 15,
            requiresScreenshot: false,
            category: "生活"
        )
    ]

    /// 按分类分组
    static var grouped: [String: [TaskTemplate]] {
        Dictionary(grouping: all, by: { $0.category })
    }

    /// 所有分类
    static var categories: [String] {
        Array(Set(all.map { $0.category })).sorted()
    }
}
