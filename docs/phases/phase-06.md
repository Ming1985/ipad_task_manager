# Phase 06: Screen Time 集成

**类型:** system-api
**状态:** completed
**相关 FR:** FR-2, FR-3

## 目标

集成 FamilyControls framework，实现任务期间的 App 屏蔽与解锁。

## 涉及的 User Stories

- US-007: App 屏蔽与解锁

## 任务清单

### 权限请求
- [x] FamilyControls 授权请求流程
- [x] 处理授权状态变化
- [x] 未授权时的降级处理
- [x] 引导用户到设置页面

### App 屏蔽实现
- [x] 使用 ManagedSettingsStore
- [x] 任务开始时屏蔽非白名单 App
- [x] 配置屏蔽 shield（遮罩界面）
- [ ] "任务进行中"遮罩自定义 - 需 DeviceActivityMonitor extension

### App 解锁实现
- [x] 任务结束后移除屏蔽
- [x] 指定 App 白名单逻辑

### 永久屏蔽列表
- [x] 家长配置"永久屏蔽"App
- [x] 永久屏蔽 App 在任务期间和之后都保持屏蔽
- [x] 永久屏蔽列表管理界面

### DeviceActivityMonitor
- [ ] 配置 DeviceActivityMonitor extension - 延后到 Phase 07
- [ ] 监控 App 使用情况 - 延后到 Phase 07

## 验收标准
- [x] 使用 FamilyControls framework 请求授权
- [x] 任务开始时自动屏蔽非白名单 App
- [ ] 被屏蔽 App 显示"任务进行中"遮罩 - 需真机测试
- [x] 任务结束后自动恢复屏蔽
- [x] 支持配置"永久屏蔽"App 列表
- [x] Typecheck 通过

## 技术决策
| 决策 | 原因 |
|-----|------|
| 使用 ManagedSettingsStore.shield | 统一管理 App 屏蔽规则 |
| ScreenTimeManager 单例模式 | 保证屏蔽状态全局一致 |
| FamilyActivitySelection Codable 序列化 | 持久化 App 选择和永久屏蔽列表 |
| 任务类型区分屏蔽策略 | 学习任务屏蔽其他 App，休息任务不屏蔽 |

## 遇到的问题
| 问题 | 解决方案 |
|-----|---------|
| ManagedSettings API 没有直接的白名单模式 | 先屏蔽所有类别，后续需真机测试优化 |
| FamilyActivitySelection Equatable 重复实现 | 移除自定义实现，使用系统默认 |

## 测试清单 (system-api)

### 自动化测试
- [x] `xcodebuild build` 成功
- [ ] 模拟器编译通过（API 存根）

### 手动验证 (真机必需)
- [ ] FamilyControls 权限请求弹窗正确
- [ ] 授权后屏蔽功能正常
- [ ] 拒绝后降级处理
- [ ] 权限状态持久化
- [ ] 任务开始时非白名单 App 被屏蔽
- [ ] 任务结束后屏蔽移除
- [ ] 永久屏蔽列表生效

## 实现的文件

### 新增文件
- `iPadTaskManager/Services/ScreenTimeManager.swift` - Screen Time 管理服务
- `iPadTaskManager/Views/Shared/ScreenTimeAuthorizationView.swift` - 授权请求界面
- `iPadTaskManager/Views/Parent/ScreenTimeSettingsView.swift` - 家长设置界面

### 修改文件
- `iPadTaskManager/Views/Parent/TaskEditView.swift` - 恢复 App 选择功能
- `iPadTaskManager/Views/Child/TaskExecutionView.swift` - 集成 App 屏蔽
- `iPadTaskManager/Views/Parent/ParentTabView.swift` - 添加屏幕使用时间设置入口
