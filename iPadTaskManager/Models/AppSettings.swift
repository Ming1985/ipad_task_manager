import Foundation
import SwiftData

/// App 设置
@Model
final class AppSettings {
    /// 当前积分余额
    var currentPoints: Int

    /// 连续完成任务数
    var streakCount: Int

    /// 最后任务完成时间
    var lastTaskCompletedAt: Date?

    /// 是否开启音效
    var soundEnabled: Bool

    /// 无操作提醒阈值（秒）
    var inactivityAlertSeconds: Int

    /// 永久屏蔽 App 列表（Data 序列化）
    var permanentBlockedApps: Data?

    /// 游戏 App 列表（Data 序列化）
    var gameApps: Data?

    /// 当前游戏时间剩余（秒）
    var remainingGameTimeSeconds: Int

    /// 游戏时间开始时间
    var gameTimeStartedAt: Date?

    init() {
        self.currentPoints = 0
        self.streakCount = 0
        self.soundEnabled = true
        self.inactivityAlertSeconds = 60
        self.remainingGameTimeSeconds = 0
    }

    /// 增加积分
    func addPoints(_ amount: Int) {
        currentPoints += amount
    }

    /// 消费积分
    func spendPoints(_ amount: Int) -> Bool {
        guard currentPoints >= amount else { return false }
        currentPoints -= amount
        return true
    }

    /// 更新连击
    func updateStreak() {
        let now = Date()
        if let lastCompleted = lastTaskCompletedAt {
            // 如果距离上次完成超过 24 小时，重置连击
            if now.timeIntervalSince(lastCompleted) > 86400 {
                streakCount = 1
            } else {
                streakCount += 1
            }
        } else {
            streakCount = 1
        }
        lastTaskCompletedAt = now
    }

    /// 开始游戏时间
    func startGameTime(minutes: Int) {
        remainingGameTimeSeconds = minutes * 60
        gameTimeStartedAt = Date()
    }

    /// 结束游戏时间
    func endGameTime() {
        remainingGameTimeSeconds = 0
        gameTimeStartedAt = nil
    }
}
