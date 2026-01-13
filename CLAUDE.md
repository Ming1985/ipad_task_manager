# iPad 儿童任务管理器

## 关键文件
@docs/ROADMAP.md
@docs/session.md

## 项目概述

面向小学生（7-12岁）的原生 iPadOS 任务管理应用。家长通过管理员模式设置学习任务和 App 使用时间，孩子完成任务获得积分兑换游戏时间。通过 Screen Time API 实现 App 屏蔽与解锁。

## 技术栈

- **语言/框架:** Swift, SwiftUI, Combine
- **最低版本:** iPadOS 17.0
- **数据持久化:** SwiftData 或 Core Data
- **核心依赖:**
  - FamilyControls（App 屏蔽）
  - DeviceActivity（使用监控）
  - ManagedSettings（屏幕时间设置）
  - UNUserNotificationCenter（本地通知）

## 开发规范

### 代码规范
- SwiftUI 视图保持简洁，复杂逻辑抽取到 ViewModel
- 使用 @Observable 或 ObservableObject 管理状态
- 类型注解完整
- 中文注释，简洁

### 提交规范
- 每个 User Story 完成后提交
- Commit message: `feat(US-xxx): 简要描述`
- 修复: `fix(US-xxx): 简要描述`

## 工作流程

### Session 开始
读取 docs/session.md 了解当前状态，直接继续工作

### 开发中
- 完成任务 → 勾选 phase 文件 checkbox
- 遇到错误 → 记录到 phase 文件「遇到的问题」表
- 做决策 → 记录到 phase 文件「技术决策」表

### 保存进度
运行 `/checkpoint` 更新所有状态文件

### Phase 完成时
1. 完成「测试清单」中的所有项目
2. 验收标准全部通过
3. 更新 ROADMAP.md 状态

## 项目特定规则

### 功能约束
- FR-5: 管理员模式需密码验证，孩子模式无需密码
- FR-6: 任务计时精确到秒，后台运行时继续计时
- FR-8: 截图存储在 App 沙盒目录，不污染系统相册
- FR-10: 积分数值为整数，最小单位为 1 分

### 设计约束
- 孩子界面：大按钮、鲜艳颜色、卡通图标、最少文字
- 家长界面：专业简洁、表格布局、详细数据展示
- 两种模式视觉风格明显区分

### 平台限制
- 仅支持 iPad，不支持 iPhone
- 纯离线使用，无网络依赖功能
- 单设备单用户设计

### Screen Time API 注意事项
- FamilyControls 需要用户在设置中授权家长控制
- Screen Time API 不提供具体 App 名称，只提供 token
- 后台运行限制可能影响计时精度
- 需真机测试 FamilyControls 功能

## 数据模型

核心实体（定义在 Phase 01）：
- Task: 任务
- TaskPlan: 任务计划
- TaskSession: 任务执行记录
- Reward: 奖励项目
- PointTransaction: 积分交易记录
- Screenshot: 截图记录
- AppUsageLog: App 使用日志

## 测试要求

- 模拟器：UI 和基础功能测试
- 真机：Screen Time API、通知、性能测试
- 测试设备：iPad Pro 13-inch (M4) 模拟器
