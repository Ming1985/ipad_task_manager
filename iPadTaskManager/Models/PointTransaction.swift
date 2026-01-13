import Foundation
import SwiftData

/// 积分交易记录
@Model
final class PointTransaction {
    /// 交易类型
    enum TransactionType: String, Codable {
        case earn = "earn"           // 获得（完成任务）
        case spend = "spend"         // 消费（兑换奖励）
        case adjust = "adjust"       // 调整（家长手动）
        case bonus = "bonus"         // 奖励（连击、计划完成等）
    }

    /// 积分数量（正数为获得，负数为消费）
    var amount: Int

    /// 交易类型
    var typeRaw: String

    var transactionType: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .earn }
        set { typeRaw = newValue.rawValue }
    }

    /// 描述
    var transactionDescription: String

    /// 关联的任务会话（如果是任务完成获得）
    @Relationship
    var session: TaskSession?

    /// 关联的奖励（如果是兑换消费）
    @Relationship
    var reward: Reward?

    /// 交易时间
    var createdAt: Date

    /// 交易后余额
    var balanceAfter: Int

    init(
        amount: Int,
        transactionType: TransactionType,
        description: String,
        balanceAfter: Int,
        session: TaskSession? = nil,
        reward: Reward? = nil
    ) {
        self.amount = amount
        self.typeRaw = transactionType.rawValue
        self.transactionDescription = description
        self.balanceAfter = balanceAfter
        self.session = session
        self.reward = reward
        self.createdAt = Date()
    }
}
