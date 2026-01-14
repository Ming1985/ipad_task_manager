import SwiftUI
import SwiftData
// import FamilyControls  // 临时禁用：需要付费开发者账号

/// 任务编辑/创建视图
struct TaskEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?
    let templateToUse: TaskTemplate?
    let customTemplateToUse: TaskItem?

    @State private var name = ""
    @State private var taskDescription = ""
    @State private var durationMinutes = 30
    @State private var pointsReward = 10
    @State private var requiresScreenshot = false
    @State private var taskType = "study"
    @State private var showAppPicker = false
    // @State private var selectedApps = FamilyActivitySelection()  // 临时禁用
    @State private var selectedAppCount = 0  // 临时替代：真机测试时恢复 FamilyActivitySelection
    @State private var showSaveAsTemplateAlert = false
    @State private var saveAsTemplate = false

    init(task: TaskItem? = nil, template: TaskTemplate? = nil, customTemplate: TaskItem? = nil) {
        self.existingTask = task
        self.templateToUse = template
        self.customTemplateToUse = customTemplate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("任务名称", text: $name)
                    TextField("任务描述（可选）", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("任务类型") {
                    Picker("类型", selection: $taskType) {
                        Text("学习任务").tag("study")
                        Text("休息/游戏").tag("rest")
                    }
                    .pickerStyle(.segmented)

                    if taskType == "rest" {
                        Text("休息任务期间可使用指定的 App")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("任务设置") {
                    Stepper("时长：\(durationMinutes) 分钟", value: $durationMinutes, in: 5...180, step: 5)

                    Stepper("积分奖励：\(pointsReward)", value: $pointsReward, in: 0...100, step: 5)

                    Toggle("需要截图验证", isOn: $requiresScreenshot)
                }

                Section("指定应用") {
                    // 临时禁用：真机测试时恢复 FamilyActivityPicker
                    Button {
                        // showAppPicker = true  // 临时禁用
                    } label: {
                        HStack {
                            Text("选择应用")
                            Spacer()
                            Text("需真机测试")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .disabled(true)  // 临时禁用

                    Text("App 选择功能需要真机和付费开发者账号")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                // 保存为模板按钮（仅在新建或编辑现有任务时显示）
                if existingTask != nil || templateToUse == nil {
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            showSaveAsTemplateAlert = true
                        } label: {
                            Label("保存为模板", systemImage: "bookmark")
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            // .familyActivityPicker(isPresented: $showAppPicker, selection: $selectedApps)  // 临时禁用
            .alert("保存为模板", isPresented: $showSaveAsTemplateAlert) {
                Button("取消", role: .cancel) { }
                Button("保存") {
                    saveAsTemplate = true
                    saveTask()
                }
            } message: {
                Text("将当前任务保存为模板，以便快速创建相似任务")
            }
            .onAppear {
                loadTaskData()
            }
        }
    }

    // 临时禁用：真机测试时恢复
    // private var selectedAppsCount: String {
    //     let count = selectedApps.applicationTokens.count
    //     return count == 0 ? "未选择" : "\(count) 个"
    // }

    private var navigationTitle: String {
        switch (existingTask, templateToUse, customTemplateToUse) {
        case (.some, _, _): return "编辑任务"
        case (_, .some, _), (_, _, .some): return "从模板创建"
        default: return "新建任务"
        }
    }

    private func loadTaskData() {
        // 优先加载现有任务
        if let task = existingTask {
            name = task.name
            taskDescription = task.taskDescription
            durationMinutes = task.durationMinutes
            pointsReward = task.pointsReward
            requiresScreenshot = task.requiresScreenshot
            taskType = task.taskType

            // TODO: 从 task.allowedApps 恢复 selectedApps
            // FamilyActivitySelection 无法直接从 Data 反序列化
        }
        // 如果是从预设模板创建，加载模板数据
        else if let template = templateToUse {
            name = template.name
            taskDescription = template.description
            durationMinutes = template.durationMinutes
            pointsReward = template.pointsReward
            requiresScreenshot = template.requiresScreenshot
            // 预设模板默认为学习任务
            taskType = "study"
        }
        // 如果是从自定义模板创建，加载模板数据
        else if let customTemplate = customTemplateToUse {
            name = customTemplate.name
            taskDescription = customTemplate.taskDescription
            durationMinutes = customTemplate.durationMinutes
            pointsReward = customTemplate.pointsReward
            requiresScreenshot = customTemplate.requiresScreenshot
            taskType = customTemplate.taskType
        }
    }

    private func saveTask() {
        // 如果是保存为模板，创建新的模板任务
        if saveAsTemplate {
            let template = TaskItem(
                name: name.trimmingCharacters(in: .whitespaces),
                taskDescription: taskDescription.trimmingCharacters(in: .whitespaces),
                durationMinutes: durationMinutes,
                pointsReward: pointsReward,
                requiresScreenshot: requiresScreenshot,
                taskType: taskType,
                isTemplate: true
            )

            // 临时禁用：真机测试时恢复 App tokens 保存
            // do {
            //     template.allowedAppTokens = try JSONEncoder().encode(selectedApps)
            // } catch {
            //     print("Failed to encode app selection: \(error)")
            // }

            modelContext.insert(template)
            saveAsTemplate = false
            dismiss()
            return
        }

        // 正常保存任务
        let templateName = templateToUse?.name ?? customTemplateToUse?.name
        let taskToSave = existingTask ?? TaskItem(
            name: "",
            taskDescription: "",
            durationMinutes: 30,
            pointsReward: 10,
            isTemplate: false,
            templateName: templateName
        )

        taskToSave.name = name.trimmingCharacters(in: .whitespaces)
        taskToSave.taskDescription = taskDescription.trimmingCharacters(in: .whitespaces)
        taskToSave.durationMinutes = durationMinutes
        taskToSave.pointsReward = pointsReward
        taskToSave.requiresScreenshot = requiresScreenshot
        taskToSave.taskType = taskType

        // 临时禁用：真机测试时恢复 App tokens 保存
        // do {
        //     taskToSave.allowedAppTokens = try JSONEncoder().encode(selectedApps)
        // } catch {
        //     print("Failed to encode app selection: \(error)")
        // }

        if existingTask == nil {
            modelContext.insert(taskToSave)
        }

        dismiss()
    }
}

#Preview {
    TaskEditView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
