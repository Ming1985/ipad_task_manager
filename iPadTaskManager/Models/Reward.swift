import Foundation
import SwiftData

/// 奖励项目
@Model
final class Reward {
    /// 奖励类型
    enum RewardType: String, Codable {
        case gameTime = "game_time"       // 游戏时间
        case custom = "custom"            // 自定义奖励（需家长确认）
    }

    /// 奖励名称
    var name: String

    /// 奖励描述
    var rewardDescription: String

    /// 所需积分
    var pointsCost: Int

    /// 奖励类型
    var typeRaw: String

    var rewardType: RewardType {
        get { RewardType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    /// 游戏时间（分钟）- 仅 gameTime 类型
    var gameTimeMinutes: Int?

    /// 解锁的 App token - 仅 gameTime 类型
    var unlockAppTokens: Data?

    /// 图标名称（SF Symbol）
    var iconName: String

    /// 是否启用
    var isEnabled: Bool

    /// 是否为预设奖励
    var isPreset: Bool

    /// 创建时间
    var createdAt: Date

    init(
        name: String,
        rewardDescription: String = "",
        pointsCost: Int,
        rewardType: RewardType = .custom,
        gameTimeMinutes: Int? = nil,
        iconName: String = "gift",
        isPreset: Bool = false
    ) {
        self.name = name
        self.rewardDescription = rewardDescription
        self.pointsCost = pointsCost
        self.typeRaw = rewardType.rawValue
        self.gameTimeMinutes = gameTimeMinutes
        self.iconName = iconName
        self.isEnabled = true
        self.isPreset = isPreset
        self.createdAt = Date()
    }

    /// 预设游戏时间奖励
    static func presetGameTime(minutes: Int, pointsCost: Int) -> Reward {
        Reward(
            name: "\(minutes)分钟游戏时间",
            rewardDescription: "可以玩\(minutes)分钟游戏",
            pointsCost: pointsCost,
            rewardType: .gameTime,
            gameTimeMinutes: minutes,
            iconName: minutes >= 60 ? "gamecontroller.fill" : "gamecontroller",
            isPreset: true
        )
    }

    /// 预设奖励：30分钟游戏时间
    static func preset30MinGameTime() -> Reward {
        presetGameTime(minutes: 30, pointsCost: 100)
    }

    /// 预设奖励：60分钟游戏时间
    static func preset60MinGameTime() -> Reward {
        presetGameTime(minutes: 60, pointsCost: 180)
    }
}
