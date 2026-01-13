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

    /// 是否首次启动
    var isFirstLaunch: Bool {
        !isPasswordSet
    }

    /// 切换到家长模式（需要验证密码）
    func switchToParentMode() {
        showPasswordPrompt = true
    }

    /// 密码验证成功后调用
    func onPasswordVerified() {
        currentMode = .parent
        showPasswordPrompt = false
    }

    /// 切换回孩子模式
    func switchToChildMode() {
        currentMode = .child
    }
}
