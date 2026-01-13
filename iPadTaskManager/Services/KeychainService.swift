import CommonCrypto
import Foundation
import Security

/// Keychain 服务 - 安全存储密码和敏感数据
enum KeychainService {
    private static let service = "com.example.iPadTaskManager"

    enum Key: String {
        case passwordHash = "admin_password_hash"
        case securityQuestion = "security_question"
        case securityAnswer = "security_answer_hash"
        case lockEndTime = "lock_end_time"
        case failedAttempts = "failed_attempts"
    }

    // MARK: - 密码管理

    /// 保存密码（存储 SHA256 哈希）
    static func savePassword(_ password: String) -> Bool {
        let hash = sha256(password)
        return saveString(hash, for: .passwordHash)
    }

    /// 验证密码
    static func verifyPassword(_ password: String) -> Bool {
        guard let savedHash = getString(for: .passwordHash) else {
            return false
        }
        return sha256(password) == savedHash
    }

    /// 检查是否已设置密码
    static func hasPassword() -> Bool {
        return getString(for: .passwordHash) != nil
    }

    /// 删除密码（重置时使用）
    static func deletePassword() -> Bool {
        return delete(key: .passwordHash)
    }

    // MARK: - 安全问题

    /// 保存安全问题和答案
    static func saveSecurityQuestion(_ question: String, answer: String) -> Bool {
        let answerHash = sha256(answer.lowercased().trimmingCharacters(in: .whitespaces))
        let questionSaved = saveString(question, for: .securityQuestion)
        let answerSaved = saveString(answerHash, for: .securityAnswer)
        return questionSaved && answerSaved
    }

    /// 获取安全问题
    static func getSecurityQuestion() -> String? {
        return getString(for: .securityQuestion)
    }

    /// 验证安全问题答案
    static func verifySecurityAnswer(_ answer: String) -> Bool {
        guard let savedHash = getString(for: .securityAnswer) else {
            return false
        }
        let answerHash = sha256(answer.lowercased().trimmingCharacters(in: .whitespaces))
        return answerHash == savedHash
    }

    // MARK: - 锁定状态

    /// 保存锁定结束时间
    static func saveLockEndTime(_ date: Date) {
        let timestamp = String(date.timeIntervalSince1970)
        _ = saveString(timestamp, for: .lockEndTime)
    }

    /// 获取锁定结束时间
    static func getLockEndTime() -> Date? {
        guard let timestamp = getString(for: .lockEndTime),
              let interval = Double(timestamp) else {
            return nil
        }
        let date = Date(timeIntervalSince1970: interval)
        // 如果锁定时间已过，清除记录
        if date < Date() {
            _ = delete(key: .lockEndTime)
            return nil
        }
        return date
    }

    /// 清除锁定状态
    static func clearLockState() {
        _ = delete(key: .lockEndTime)
        _ = delete(key: .failedAttempts)
    }

    /// 保存失败次数
    static func saveFailedAttempts(_ count: Int) {
        _ = saveString(String(count), for: .failedAttempts)
    }

    /// 获取失败次数
    static func getFailedAttempts() -> Int {
        guard let countStr = getString(for: .failedAttempts),
              let count = Int(countStr) else {
            return 0
        }
        return count
    }

    // MARK: - 私有方法

    private static func saveString(_ value: String, for key: Key) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // 先删除旧值
        _ = delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private static func getString(for key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    private static func delete(key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// SHA256 哈希
    private static func sha256(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
