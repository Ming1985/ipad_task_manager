import Foundation
import SwiftData

/// App 使用日志
@Model
final class AppUsageLog {
    /// 日志类型
    enum LogType: String, Codable {
        case appSwitch = "app_switch"     // App 切换
        case violation = "violation"       // 违规（使用非指定 App）
        case inactivity = "inactivity"     // 无操作
    }

    /// 日志类型
    var typeRaw: String

    var logType: LogType {
        get { LogType(rawValue: typeRaw) ?? .appSwitch }
        set { typeRaw = newValue.rawValue }
    }

    /// App token（使用 Data 存储）
    var appToken: Data?

    /// 使用时长（秒）
    var durationSeconds: Int

    /// 关联的任务会话
    @Relationship
    var session: TaskSession?

    /// 记录时间
    var loggedAt: Date

    /// 额外信息
    var notes: String?

    init(
        logType: LogType,
        durationSeconds: Int = 0,
        session: TaskSession? = nil,
        notes: String? = nil
    ) {
        self.typeRaw = logType.rawValue
        self.durationSeconds = durationSeconds
        self.session = session
        self.loggedAt = Date()
        self.notes = notes
    }
}
