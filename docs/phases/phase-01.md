# Phase 01: 基础架构

**类型:** infrastructure
**状态:** completed
**相关 FR:** FR-1, FR-4

## 目标

搭建项目基础框架，包括 Xcode 项目配置、基础导航结构、核心数据模型定义。

## 涉及的 User Stories

- 无直接关联的 US（基础设施）

## 任务清单

### 项目初始化
- [x] 创建 Xcode 项目（iPadOS 17.0+，SwiftUI）
- [x] 配置 Bundle ID 和签名
- [x] 添加 FamilyControls、DeviceActivity、ManagedSettings framework
- [x] 配置 Info.plist 权限描述

### 导航结构
- [x] 创建 App 入口和主导航
- [x] 实现孩子模式/家长模式切换逻辑
- [x] 创建 TabView 或 NavigationStack 基础结构

### 数据层
- [x] 配置 SwiftData
- [x] 定义核心数据模型：
  - [x] TaskItem（任务）
  - [x] TaskPlan（任务计划）
  - [x] TaskSession（执行记录）
  - [x] Reward（奖励）
  - [x] PointTransaction（积分记录）
  - [x] Screenshot（截图）
  - [x] AppUsageLog（使用日志）
- [x] 创建 ModelContainer 封装

### 工具类
- [x] 创建通用 View 扩展
- [x] 创建颜色/字体常量（AppColors、AppFonts）

## 验收标准
- [x] App 编译通过且能在模拟器启动
- [x] 导航结构正常切换
- [x] 数据模型可正常创建和读取
- [x] Typecheck 通过

## 技术决策
| 决策 | 原因 |
|-----|------|
| 使用 SwiftData 而非 Core Data | SwiftData 更现代，与 SwiftUI 集成更好 |
| 目标版本改为 iOS 17.0 | SwiftData @Model 宏需要 iOS 17+ |
| 使用 ObservableObject 而非 @Observable | 保持与现有代码一致性 |

## 遇到的问题
| 问题 | 解决方案 |
|-----|---------|
| @Observable 需要 iOS 17+ | 改用 ObservableObject + @Published |
| SwiftData 需要 iOS 17+ | 将目标版本从 16.0 改为 17.0 |
| 测试 target 缺少 Info.plist | 在 project.yml 添加 GENERATE_INFOPLIST_FILE: YES |

## 测试清单 (infrastructure)

### 自动化测试
- [x] `xcodebuild clean build -scheme iPadTaskManager -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'` 成功
- [x] `xcodebuild test -scheme iPadTaskManager -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'` 通过
- [x] 模拟器启动无崩溃：`xcrun simctl launch 'iPad (A16)' com.example.iPadTaskManager`

### 手动验证
- [x] 导航结构正确渲染（UI 测试验证：首次启动界面、TabView 结构）
- [x] 内存无明显泄漏（基础架构阶段无循环引用，后续 Phase 继续监控）
