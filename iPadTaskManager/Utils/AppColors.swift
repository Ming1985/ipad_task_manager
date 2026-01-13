import SwiftUI

/// App 配色常量
enum AppColors {
    // MARK: - 主色调

    /// 主色：蓝色（学习）
    static let primary = Color.blue

    /// 完成色：绿色
    static let success = Color.green

    /// 奖励色：橙色
    static let reward = Color.orange

    /// 警告色：红色
    static let warning = Color.red

    // MARK: - 孩子界面

    /// 孩子界面背景：渐变浅色
    static let childBackground = LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 孩子界面卡片背景
    static let childCardBackground = Color(uiColor: .systemBackground)

    // MARK: - 家长界面

    /// 家长界面强调色
    static let parentAccent = Color.indigo

    /// 家长界面背景
    static let parentBackground = Color(uiColor: .systemGroupedBackground)

    // MARK: - 任务卡片配色

    /// 待完成任务
    static let taskPending = Color.blue.opacity(0.1)

    /// 进行中任务
    static let taskInProgress = Color.orange.opacity(0.2)

    /// 已完成任务
    static let taskCompleted = Color.green.opacity(0.1)
}

/// App 字体常量
enum AppFonts {
    // MARK: - 孩子界面（大字体）

    /// 任务标题
    static let childTitle = Font.title.weight(.bold)

    /// 任务描述
    static let childBody = Font.title3

    /// 积分显示
    static let childPoints = Font.system(size: 48, weight: .bold)

    // MARK: - 家长界面（标准字体）

    /// 标题
    static let parentTitle = Font.headline

    /// 正文
    static let parentBody = Font.body

    /// 说明
    static let parentCaption = Font.caption
}
