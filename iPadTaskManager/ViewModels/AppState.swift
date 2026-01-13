import SwiftUI

/// App 全局状态
final class AppState: ObservableObject {
    /// 当前模式
    enum Mode {
        case child   // 孩子模式
        case parent  // 家长模式
    }

    /// 当前模式，默认孩子模式
    @Published var currentMode: Mode = .child

    /// 是否已设置管理员密码
    @Published var isPasswordSet: Bool = false

    /// 是否显示密码输入界面
    @Published var showPasswordPrompt: Bool = false

    /// 是否显示密码重置界面
    @Published var showPasswordReset: Bool = false

    /// 是否首次启动
    var isFirstLaunch: Bool {
        !isPasswordSet
    }

    init() {
        // 从 Keychain 检查是否已设置密码
        isPasswordSet = KeychainService.hasPassword()
    }

    /// 切换到家长模式（需要验证密码）
    func switchToParentMode() {
        showPasswordPrompt = true
    }

    /// 密码验证成功后调用
    func onPasswordVerified() {
        currentMode = .parent
        showPasswordPrompt = false
        // 清除锁定状态
        KeychainService.clearLockState()
    }

    /// 切换回孩子模式
    func switchToChildMode() {
        currentMode = .child
    }

    /// 密码设置完成
    func onPasswordSet() {
        isPasswordSet = true
    }

    /// 显示密码重置
    func showResetPassword() {
        showPasswordReset = true
    }
}
