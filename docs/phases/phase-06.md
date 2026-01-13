# Phase 06: Screen Time 集成

**类型:** system-api
**状态:** pending
**相关 FR:** FR-2, FR-3

## 目标

集成 FamilyControls framework，实现任务期间的 App 屏蔽与解锁。

## 涉及的 User Stories

- US-007: App 屏蔽与解锁

## 任务清单

### 权限请求
- [ ] FamilyControls 授权请求流程
- [ ] 处理授权状态变化
- [ ] 未授权时的降级处理
- [ ] 引导用户到设置页面

### App 屏蔽实现
- [ ] 使用 ManagedSettingsStore
- [ ] 任务开始时屏蔽非白名单 App
- [ ] 配置屏蔽 shield（遮罩界面）
- [ ] "任务进行中"遮罩自定义

### App 解锁实现
- [ ] 任务结束后移除屏蔽
- [ ] 指定 App 白名单逻辑

### 永久屏蔽列表
- [ ] 家长配置"永久屏蔽"App
- [ ] 永久屏蔽 App 在任务期间和之后都保持屏蔽
- [ ] 永久屏蔽列表管理界面

### DeviceActivityMonitor
- [ ] 配置 DeviceActivityMonitor extension
- [ ] 监控 App 使用情况

## 验收标准
- [ ] 使用 FamilyControls framework 请求授权
- [ ] 任务开始时自动屏蔽非白名单 App
- [ ] 被屏蔽 App 显示"任务进行中"遮罩
- [ ] 任务结束后自动恢复屏蔽
- [ ] 支持配置"永久屏蔽"App 列表
- [ ] Typecheck 通过

## 技术决策
| 决策 | 原因 |
|-----|------|

## 遇到的问题
| 问题 | 解决方案 |
|-----|---------|

## 测试清单 (system-api)

### 自动化测试
- [ ] `xcodebuild build` 成功
- [ ] 模拟器编译通过（API 存根）

### 手动验证 (真机必需)
- [ ] FamilyControls 权限请求弹窗正确
- [ ] 授权后屏蔽功能正常
- [ ] 拒绝后降级处理
- [ ] 权限状态持久化
- [ ] 任务开始时非白名单 App 被屏蔽
- [ ] 任务结束后屏蔽移除
- [ ] 永久屏蔽列表生效
