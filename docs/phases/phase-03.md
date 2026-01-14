# Phase 03: 任务管理

**类型:** ui
**状态:** completed
**相关 FR:** FR-4, FR-6

## 目标

实现家长端任务和任务计划的创建、编辑功能，包括任务模板。

## 涉及的 User Stories

- US-002: 创建单个任务
- US-003: 创建任务序列（计划）
- US-019: 任务模板

## 任务清单

### 单个任务管理
- [x] 任务列表界面（家长端）
- [x] 任务创建表单：
  - [x] 名称、描述输入
  - [x] 时长设置（分钟）
  - [x] App 选择器（支持多选）
  - [x] 积分奖励设置
  - [x] 是否需要截图开关
- [x] 任务编辑功能
- [x] 任务删除功能

### 任务计划管理
- [x] 计划列表界面
- [x] 计划创建：
  - [x] 名称输入
  - [x] 添加任务到计划
  - [x] 拖拽调整任务顺序
  - [x] 总时长自动计算显示
- [x] 计划时间设置（固定时间段/随时可开始）
- [x] 计划完成额外奖励设置
- [x] 计划编辑和删除

### 任务模板
- [x] 预设模板列表（阅读、数学、英语、钢琴等）
- [x] 从模板创建任务（弹出编辑界面预填充）
- [x] 将任务保存为模板

### App 选择器
- [x] 使用 FamilyActivityPicker 选择 App
- [ ] 显示已选 App 图标 - 需要真机测试

### 补充功能（Phase 03.1）
- [x] 删除任务确认对话框
- [x] 模板点击弹出编辑界面（而非直接创建）
- [x] 任务类型（学习任务/休息游戏）
- [x] 计划时间模式设置（固定时间段/随时可开始）
- [x] 计划中任务时长微调（+/- 1分钟）

## 验收标准
- [x] 任务包含：名称、描述、时长、类型、指定 App、积分、截图选项
- [x] 计划包含：名称、任务列表（有序）、时间模式、总时长、额外奖励
- [x] 支持拖拽调整任务顺序
- [x] 模板功能正常（点击弹出编辑界面）
- [x] 数据保存到本地数据库
- [x] Typecheck 通过

## 技术决策
| 决策 | 原因 |
|-----|------|
| 使用 SwiftUI Form 构建表单 | 原生体验，自动处理键盘、滚动 |
| FamilyActivityPicker 集成 | 系统提供的 App 选择器，保证权限正确 |
| 任务选择器 + 拖拽排序 | onMove modifier 实现任务排序 |
| 任务类型用 String 存储 | SwiftData 对 enum 支持有限 |
| 时长覆盖用 JSON Data 存储 | 避免创建额外的关联模型 |
| 添加 taskId 字段 | SwiftData 自动生成的 id 不是 UUID 类型 |

## 遇到的问题
| 问题 | 解决方案 |
|-----|---------|
| TaskPlan 模型字段命名不一致 | 使用 `tasks` 而非 `taskItems` |
| TaskItem 模型字段命名错误 | 使用 `allowedAppTokens` 而非 `allowedApps` |
| SwiftData id 类型问题 | 添加显式的 `taskId: UUID` 字段 |
| 类方法不能用 mutating | 移除 mutating 关键字 |

## 测试清单 (ui)

### 自动化测试
- [x] `xcodebuild build` 成功
- [x] `xcodebuild test` UI 测试通过（如有 XCUITest）- 暂无 XCUITest

### 手动验证（模拟器）
- [x] 表单布局正确
- [x] 输入验证正常（必填项、数值范围）
- [x] 拖拽排序流畅
- [x] 数据保存后重启仍存在
- [x] 横屏/竖屏适配

### 真机测试, 等待未来执行
详见 `docs/pending-device-tests.org`

- [ ] App 选择器正常弹出（FamilyActivityPicker）
- [ ] App 图标显示正确

## 实现的文件

### 新增文件
- `iPadTaskManager/Views/Parent/ParentTaskListView.swift` - 任务列表视图
- `iPadTaskManager/Views/Parent/TaskEditView.swift` - 任务创建/编辑表单（支持模板）
- `iPadTaskManager/Views/Parent/ParentPlanListView.swift` - 任务计划列表和模板列表
- `iPadTaskManager/Views/Parent/PlanEditView.swift` - 计划创建/编辑（含任务选择器）

### 修改文件
- `iPadTaskManager/Models/TaskItem.swift` - 添加任务模板结构和预设模板
- `iPadTaskManager/Views/Parent/ParentTabView.swift` - 集成任务管理和模板 TabView
