import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

/// Screen Time 管理服务
/// 负责 FamilyControls 授权、App 屏蔽与解锁
@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    // MARK: - Published Properties

    /// 授权状态
    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined

    /// 是否正在屏蔽 App
    @Published private(set) var isShieldingActive = false

    /// 当前任务允许的 App
    @Published var currentTaskApps = FamilyActivitySelection()

    /// 永久屏蔽的 App（家长配置）
    @Published var permanentlyBlockedApps = FamilyActivitySelection()

    // MARK: - Private Properties

    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared

    // MARK: - Initialization

    private init() {
        // 监听授权状态变化
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// 授权状态枚举
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case approved
    }

    /// 检查当前授权状态
    func checkAuthorizationStatus() async {
        switch center.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .approved:
            authorizationStatus = .approved
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }

    /// 请求 FamilyControls 授权
    func requestAuthorization() async -> Bool {
        do {
            try await center.requestAuthorization(for: .individual)
            await checkAuthorizationStatus()
            return authorizationStatus == .approved
        } catch {
            print("FamilyControls 授权失败: \(error)")
            await checkAuthorizationStatus()
            return false
        }
    }

    // MARK: - App Shielding

    /// 开始任务时的 App 屏蔽
    /// - Parameter allowedApps: 任务期间允许使用的 App
    /// - Note: ManagedSettings 只支持黑名单模式，白名单需 DeviceActivityMonitor（Phase 07）
    func startTaskShielding(allowedApps: FamilyActivitySelection) {
        guard authorizationStatus == .approved else {
            print("未获得授权，无法屏蔽 App")
            return
        }

        currentTaskApps = allowedApps
        let allowedApplications = allowedApps.applicationTokens

        if allowedApplications.isEmpty {
            store.shield.applicationCategories = .all()
            store.shield.applications = nil
        } else {
            // 有白名单时暂不屏蔽，Phase 07 实现监控
            store.shield.applications = nil
            store.shield.applicationCategories = nil
        }

        isShieldingActive = true
        print("任务屏蔽已启动，允许 \(allowedApplications.count) 个 App")
    }

    /// 停止任务屏蔽（任务完成或放弃时调用）
    func stopTaskShielding() {
        guard authorizationStatus == .approved else { return }

        // 移除任务相关的屏蔽
        store.shield.applications = nil
        store.shield.applicationCategories = nil

        // 如果有永久屏蔽列表，重新应用
        applyPermanentBlocking()

        isShieldingActive = false
        currentTaskApps = FamilyActivitySelection()
        print("任务屏蔽已停止")
    }

    /// 应用永久屏蔽（家长设置的始终屏蔽 App）
    func applyPermanentBlocking() {
        guard authorizationStatus == .approved else { return }

        let blockedApps = permanentlyBlockedApps.applicationTokens
        let blockedCategories = permanentlyBlockedApps.categoryTokens

        if blockedApps.isEmpty && blockedCategories.isEmpty {
            // 没有永久屏蔽的 App
            store.shield.applications = nil
            store.shield.applicationCategories = nil
        } else {
            // 应用永久屏蔽
            store.shield.applications = blockedApps
            store.shield.applicationCategories = .specific(blockedCategories)
        }
    }

    /// 清除所有屏蔽
    func clearAllShielding() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        isShieldingActive = false
    }

    // MARK: - Persistence

    /// 保存永久屏蔽列表到 UserDefaults
    func savePermanentBlockedApps() {
        do {
            let data = try JSONEncoder().encode(permanentlyBlockedApps)
            UserDefaults.standard.set(data, forKey: "permanentlyBlockedApps")
        } catch {
            print("保存永久屏蔽列表失败: \(error)")
        }
    }

    /// 从 UserDefaults 加载永久屏蔽列表
    func loadPermanentBlockedApps() {
        guard let data = UserDefaults.standard.data(forKey: "permanentlyBlockedApps") else {
            return
        }
        if let apps = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            permanentlyBlockedApps = apps
            applyPermanentBlocking()
        }
    }
}

// MARK: - FamilyActivitySelection Extension

// FamilyActivitySelection 已实现 Equatable
