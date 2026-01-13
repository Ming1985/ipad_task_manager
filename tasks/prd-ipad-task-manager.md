# PRD: iPad 儿童任务管理器

## Introduction

一款面向小学生（7-12岁）的原生 iPadOS 任务管理应用。家长可在同一设备上通过管理员模式设置学习任务、控制 App 使用时间，孩子完成任务后可获得积分兑换游戏时间或其他奖励。通过 iOS Screen Time API 实现 App 屏蔽与解锁。

## Goals

- 帮助家长有效管理孩子的 iPad 使用时间
- 通过任务驱动的方式培养孩子的时间管理能力
- 提供可量化的奖励机制激励任务完成
- 多维度跟踪任务执行情况，确保任务质量
- 界面友好，适合小学生独立操作

## User Stories

### US-001: 管理员密码保护
**Description:** 作为家长，我需要设置管理员密码，防止孩子擅自修改设置。

**Acceptance Criteria:**
- [ ] 首次启动 App 时强制设置 6 位数字密码
- [ ] 进入管理员模式需输入密码
- [ ] 支持密码修改和重置（通过安全问题）
- [ ] 连续 5 次输错密码后锁定 5 分钟
- [ ] Typecheck 通过

---

### US-002: 创建单个任务
**Description:** 作为家长，我要创建学习任务并指定使用的 App，让孩子有明确的目标。

**Acceptance Criteria:**
- [ ] 任务包含：名称、描述、时长（分钟）、指定 App（可多选）
- [ ] 可设置任务积分奖励值
- [ ] 可选择是否需要截图反馈
- [ ] 任务保存到本地数据库
- [ ] Typecheck 通过

---

### US-003: 创建任务序列（计划）
**Description:** 作为家长，我要创建包含多个任务的学习计划，让孩子按顺序完成。

**Acceptance Criteria:**
- [ ] 计划包含：名称、任务列表（有序）、总时长自动计算
- [ ] 支持拖拽调整任务顺序
- [ ] 可设置计划的可用时间段（如每天 16:00-18:00）
- [ ] 可设置完成整个计划的额外奖励积分
- [ ] Typecheck 通过

---

### US-004: 孩子查看任务列表
**Description:** 作为孩子，我要看到今天要做的任务，知道该做什么。

**Acceptance Criteria:**
- [ ] 主界面显示今日待完成任务/计划
- [ ] 每个任务显示：名称、时长、积分、指定 App 图标
- [ ] 已完成任务显示勾选状态和获得积分
- [ ] 界面使用大字体、鲜艳颜色，适合儿童
- [ ] Typecheck 通过
- [ ] 使用 dev-browser skill 在模拟器中验证 UI

---

### US-005: 开始单个任务
**Description:** 作为孩子，我要点击任务开始学习，App 会引导我使用正确的应用。

**Acceptance Criteria:**
- [ ] 点击"开始"按钮启动任务
- [ ] 显示任务详情和倒计时
- [ ] 弹出提示引导打开指定 App
- [ ] 调用 Screen Time API 屏蔽非指定 App
- [ ] 任务期间状态栏显示剩余时间
- [ ] Typecheck 通过

---

### US-006: 开始任务计划（序列执行）
**Description:** 作为孩子，我要开始一个学习计划，系统自动引导我依次完成所有任务。

**Acceptance Criteria:**
- [ ] 点击计划"开始"后，自动启动第一个任务
- [ ] 每个任务完成后自动切换到下一个
- [ ] 显示当前任务进度（如 2/5）
- [ ] 任务间可设置休息时间（可选）
- [ ] Typecheck 通过

---

### US-007: App 屏蔽与解锁
**Description:** 作为家长，我要在任务期间屏蔽娱乐 App，确保孩子专注学习。

**Acceptance Criteria:**
- [ ] 使用 FamilyControls framework 请求授权
- [ ] 任务开始时自动屏蔽非白名单 App
- [ ] 被屏蔽 App 显示"任务进行中"遮罩
- [ ] 任务结束后自动恢复屏蔽
- [ ] 支持配置"永久屏蔽"App 列表（如社交媒体）
- [ ] Typecheck 通过

---

### US-008: 任务完成解锁游戏时间
**Description:** 作为孩子，完成任务后我可以获得游戏时间作为奖励。

**Acceptance Criteria:**
- [ ] 任务完成后根据设置解锁指定 App
- [ ] 解锁时间根据积分兑换或家长预设
- [ ] 显示"游戏时间剩余 XX 分钟"倒计时
- [ ] 时间到后自动重新屏蔽游戏 App
- [ ] 提前 5 分钟和 1 分钟发送提醒
- [ ] Typecheck 通过

---

### US-009: App 使用情况跟踪
**Description:** 作为家长，我要了解孩子在任务期间实际使用了哪些 App。

**Acceptance Criteria:**
- [ ] 通过 Screen Time API 获取 App 使用时长数据
- [ ] 记录任务期间的 App 切换行为
- [ ] 检测是否使用了非指定 App（尝试绕过）
- [ ] 数据存储到本地，供统计查看
- [ ] Typecheck 通过

---

### US-010: 交互情况跟踪
**Description:** 作为家长，我要了解孩子在任务期间的实际操作情况。

**Acceptance Criteria:**
- [ ] 记录屏幕点击频率（判断是否活跃）
- [ ] 检测长时间无操作（可能走神）
- [ ] 无操作超过设定时间发送提醒
- [ ] 记录每次会话的活跃度评分
- [ ] Typecheck 通过

---

### US-011: 截图功能
**Description:** 作为家长，我要通过截图了解孩子的任务完成情况。

**Acceptance Criteria:**
- [ ] 支持任务期间手动截图
- [ ] 任务结束前强制提示截图（如设置了需要截图）
- [ ] 截图自动关联到对应任务
- [ ] 截图存储在 App 沙盒内，按日期组织
- [ ] 家长可在管理界面查看截图
- [ ] Typecheck 通过

---

### US-012: 任务完成提示与截图反馈
**Description:** 作为孩子，任务时间到了我需要提交成果截图。

**Acceptance Criteria:**
- [ ] 任务结束前 2 分钟发送"即将结束"通知
- [ ] 时间到后弹出截图提示界面
- [ ] 提供截图按钮和"跳过"选项（如任务不需要）
- [ ] 截图后显示预览，确认提交
- [ ] Typecheck 通过
- [ ] 使用 dev-browser skill 在模拟器中验证 UI

---

### US-013: 任务完成反馈与奖励特效
**Description:** 作为孩子，完成任务后我想看到酷炫的奖励动画。

**Acceptance Criteria:**
- [ ] 任务完成显示庆祝动画（撒花/星星特效）
- [ ] 显示获得的积分数量（数字跳动效果）
- [ ] 播放成功音效（可在设置中关闭）
- [ ] 连续完成任务显示连击奖励
- [ ] 动画结束后显示下一步选项
- [ ] Typecheck 通过
- [ ] 使用 dev-browser skill 在模拟器中验证动画效果

---

### US-014: 积分系统
**Description:** 作为孩子，我要积累积分并兑换奖励。

**Acceptance Criteria:**
- [ ] 显示当前积分余额
- [ ] 积分历史记录（获得/消费）
- [ ] 支持家长手动调整积分
- [ ] 积分数据持久化存储
- [ ] Typecheck 通过

---

### US-015: 奖励商城
**Description:** 作为孩子，我要用积分兑换游戏时间或其他奖励。

**Acceptance Criteria:**
- [ ] 显示可兑换奖励列表
- [ ] 每个奖励显示：名称、描述、所需积分、图标
- [ ] 点击兑换后扣除积分并生效
- [ ] 家长可在管理界面配置奖励项目
- [ ] 预设奖励：游戏时间（30分钟=100积分等）
- [ ] Typecheck 通过
- [ ] 使用 dev-browser skill 在模拟器中验证 UI

---

### US-016: 家长配置奖励项目
**Description:** 作为家长，我要自定义奖励项目和积分价格。

**Acceptance Criteria:**
- [ ] 添加自定义奖励（如：零花钱、外出游玩）
- [ ] 设置奖励所需积分
- [ ] 设置奖励类型：自动生效（游戏时间）/ 需家长确认
- [ ] 启用/禁用奖励项目
- [ ] Typecheck 通过

---

### US-017: 统计仪表盘
**Description:** 作为家长，我要查看孩子的任务完成统计和使用情况。

**Acceptance Criteria:**
- [ ] 显示今日/本周/本月任务完成率
- [ ] 显示各 App 使用时长饼图
- [ ] 显示积分获取/消费趋势图
- [ ] 显示任务完成时间分布
- [ ] 支持按日期范围筛选
- [ ] Typecheck 通过
- [ ] 使用 dev-browser skill 在模拟器中验证图表

---

### US-018: 通知系统
**Description:** 作为系统，我要在关键时刻发送通知提醒用户。

**Acceptance Criteria:**
- [ ] 任务开始时间到达时发送通知
- [ ] 任务即将结束时发送提醒
- [ ] 游戏时间即将结束时发送提醒
- [ ] 支持配置通知声音和振动
- [ ] 使用 iOS 本地通知 API
- [ ] Typecheck 通过

---

### US-019: 任务模板
**Description:** 作为家长，我要使用模板快速创建常用任务。

**Acceptance Criteria:**
- [ ] 预设模板：阅读、数学练习、英语学习、钢琴练习等
- [ ] 支持将已有任务保存为模板
- [ ] 从模板创建任务时可修改参数
- [ ] Typecheck 通过

---

### US-020: 数据备份与恢复
**Description:** 作为家长，我要备份数据防止丢失。

**Acceptance Criteria:**
- [ ] 支持导出数据到 iCloud
- [ ] 支持从 iCloud 恢复数据
- [ ] 导出/导入进度显示
- [ ] 恢复前确认提示
- [ ] Typecheck 通过

## Functional Requirements

- FR-1: App 使用 SwiftUI 构建，最低支持 iPadOS 16.0
- FR-2: 使用 FamilyControls framework 实现 App 屏蔽功能
- FR-3: 使用 DeviceActivity framework 监控 App 使用情况
- FR-4: 使用 Core Data 或 SwiftData 进行本地数据持久化
- FR-5: 管理员模式需密码验证，孩子模式无需密码
- FR-6: 任务计时精确到秒，后台运行时继续计时
- FR-7: 所有时间相关功能支持系统时区
- FR-8: 截图存储在 App 沙盒目录，不污染系统相册
- FR-9: 通知使用 UNUserNotificationCenter
- FR-10: 积分数值为整数，最小单位为 1 分

## Non-Goals

- 不支持多设备同步（仅限单台 iPad 使用）
- 不支持多个孩子账户（单用户设计）
- 不提供远程监控功能（家长必须在同一设备操作）
- 不包含社交功能（排行榜、分享等）
- 不支持 iPhone（仅限 iPad）
- 不做网络依赖功能（纯离线使用）
- 不做家长手机端配套 App

## Design Considerations

### UI/UX 原则
- 孩子界面：大按钮、鲜艳颜色、卡通图标、最少文字
- 家长界面：专业简洁、表格布局、详细数据展示
- 两种模式视觉风格明显区分

### 配色方案
- 主色：蓝色系（学习）、绿色系（完成）、橙色系（奖励）
- 孩子界面背景：渐变浅色
- 家长界面背景：纯白/浅灰

### 动画
- 任务完成：Lottie 动画或 SwiftUI 原生动画
- 积分增加：数字滚动效果
- 页面切换：平滑过渡

## Technical Considerations

### 框架依赖
- FamilyControls（App 屏蔽，需 iOS 16+）
- DeviceActivity（使用监控）
- ManagedSettings（屏幕时间设置）
- SwiftUI + Combine
- Core Data 或 SwiftData

### 权限要求
- Screen Time 授权（需家长 Apple ID 确认）
- 通知权限
- 相册写入权限（如需导出截图）

### 数据模型（核心实体）
- Task: 任务
- TaskPlan: 任务计划
- TaskSession: 任务执行记录
- Reward: 奖励项目
- PointTransaction: 积分交易记录
- Screenshot: 截图记录
- AppUsageLog: App 使用日志

### 限制与挑战
- FamilyControls 需要用户在设置中授权家长控制
- Screen Time API 不提供具体 App 名称，只提供 token
- 后台运行限制可能影响计时精度

## Success Metrics

- 孩子能在 3 次点击内开始一个任务
- 任务完成率数据准确度 > 99%
- App 屏蔽生效延迟 < 2 秒
- 截图功能响应时间 < 1 秒
- 家长配置一个完整任务计划 < 5 分钟

## Open Questions

1. FamilyControls 授权流程是否需要家长 Apple ID？需实际测试确认。
2. 是否需要支持 iPad 横屏和竖屏？
3. 截图是否需要自动识别内容（OCR）验证任务完成？
4. 是否需要"紧急模式"让孩子临时解锁某些 App？
5. 积分是否允许负数（预支/惩罚）？
6. 任务失败/放弃的处理逻辑是什么？
