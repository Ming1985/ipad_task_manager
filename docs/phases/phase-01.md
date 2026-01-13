# Phase 01: 基础架构

**类型:** infrastructure
**状态:** pending
**相关 FR:** FR-1, FR-4

## 目标

搭建项目基础框架，包括 Xcode 项目配置、基础导航结构、核心数据模型定义。

## 涉及的 User Stories

- 无直接关联的 US（基础设施）

## 任务清单

### 项目初始化
- [ ] 创建 Xcode 项目（iPadOS 16.0+，SwiftUI）
- [ ] 配置 Bundle ID 和签名
- [ ] 添加 FamilyControls、DeviceActivity、ManagedSettings framework
- [ ] 配置 Info.plist 权限描述

### 导航结构
- [ ] 创建 App 入口和主导航
- [ ] 实现孩子模式/家长模式切换逻辑
- [ ] 创建 TabView 或 NavigationStack 基础结构

### 数据层
- [ ] 配置 SwiftData 或 Core Data
- [ ] 定义核心数据模型：
  - [ ] Task（任务）
  - [ ] TaskPlan（任务计划）
  - [ ] TaskSession（执行记录）
  - [ ] Reward（奖励）
  - [ ] PointTransaction（积分记录）
  - [ ] Screenshot（截图）
  - [ ] AppUsageLog（使用日志）
- [ ] 创建 DataManager 或 ModelContext 封装

### 工具类
- [ ] 创建通用 View 扩展
- [ ] 创建颜色/字体常量

## 验收标准
- [ ] App 编译通过且能在模拟器启动
- [ ] 导航结构正常切换
- [ ] 数据模型可正常创建和读取
- [ ] Typecheck 通过

## 技术决策
| 决策 | 原因 |
|-----|------|

## 遇到的问题
| 问题 | 解决方案 |
|-----|---------|

## 测试清单 (infrastructure)

### 自动化测试
- [ ] `xcodebuild clean build -scheme iPadTaskManager -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'` 成功
- [ ] `xcodebuild test -scheme iPadTaskManager -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'` 通过
- [ ] 模拟器启动无崩溃：`xcrun simctl boot 'iPad Pro 13-inch (M4)' && xcrun simctl launch booted [bundle-id]`

### 手动验证
- [ ] 导航结构正确渲染
- [ ] 内存无明显泄漏（Instruments 检查）
