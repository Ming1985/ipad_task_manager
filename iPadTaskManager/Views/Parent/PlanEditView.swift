import SwiftUI
import SwiftData

/// 任务计划编辑/创建视图
struct PlanEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allTasks: [TaskItem]

    let plan: TaskPlan?

    @State private var name = ""
    @State private var selectedTasks: [TaskItem] = []
    @State private var bonusPoints = 0
    @State private var showTaskPicker = false

    // 时间设置
    @State private var mode = "flexible"
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 16, minute: 0)) ?? Date()
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()

    // 时长覆盖
    @State private var durationOverrides: [String: Int] = [:]

    init(plan: TaskPlan? = nil) {
        self.plan = plan
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("计划名称", text: $name)
                }

                Section("时间设置") {
                    Picker("计划模式", selection: $mode) {
                        Text("随时可开始").tag("flexible")
                        Text("固定时间段").tag("fixed")
                    }
                    .pickerStyle(.segmented)

                    if mode == "fixed" {
                        DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)

                        // 计划时长提示
                        let planMinutes = minutesBetween(startTime, endTime)
                        if planMinutes > 0 {
                            HStack {
                                Text("计划时长")
                                Spacer()
                                Text("\(planMinutes) 分钟")
                                    .foregroundStyle(.secondary)
                            }

                            if totalDuration > planMinutes {
                                Text("任务总时长超过计划时长 \(totalDuration - planMinutes) 分钟")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            } else if totalDuration < planMinutes {
                                Text("剩余 \(planMinutes - totalDuration) 分钟未安排")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("任务列表") {
                    if selectedTasks.isEmpty {
                        Button {
                            showTaskPicker = true
                        } label: {
                            Label("添加任务", systemImage: "plus.circle")
                        }
                    } else {
                        ForEach(selectedTasks.indices, id: \.self) { index in
                            let task = selectedTasks[index]
                            TaskRowWithDuration(
                                task: task,
                                duration: effectiveDuration(for: task),
                                onAdjust: { adjustDuration(task, by: $0) },
                                onRemove: { removeTask(at: index) }
                            )
                        }
                        .onMove(perform: moveTasks)

                        Button {
                            showTaskPicker = true
                        } label: {
                            Label("添加更多任务", systemImage: "plus.circle")
                        }
                    }

                    HStack {
                        Text("总时长")
                        Spacer()
                        Text("\(totalDuration) 分钟")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("奖励") {
                    Stepper("完成奖励：\(bonusPoints) 积分", value: $bonusPoints, in: 0...100, step: 5)
                }
            }
            .navigationTitle(plan == nil ? "新建计划" : "编辑计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        savePlan()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedTasks.isEmpty)
                }

                ToolbarItem(placement: .secondaryAction) {
                    if !selectedTasks.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showTaskPicker) {
                TaskPickerView(selectedTasks: $selectedTasks, allTasks: allTasks)
            }
            .onAppear {
                loadPlanData()
            }
        }
    }

    private var totalDuration: Int {
        selectedTasks.reduce(0) { total, task in
            total + effectiveDuration(for: task)
        }
    }

    private func effectiveDuration(for task: TaskItem) -> Int {
        if let override = durationOverrides[task.taskId.uuidString] {
            return override
        }
        return task.durationMinutes
    }

    private func adjustDuration(_ task: TaskItem, by amount: Int) {
        let currentDuration = effectiveDuration(for: task)
        let newDuration = max(1, currentDuration + amount)
        durationOverrides[task.taskId.uuidString] = newDuration
    }

    private func minutesBetween(_ start: Date, _ end: Date) -> Int {
        let components = Calendar.current.dateComponents([.minute], from: start, to: end)
        return max(0, components.minute ?? 0)
    }

    private func removeTask(at index: Int) {
        guard index < selectedTasks.count else { return }
        selectedTasks.remove(at: index)
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        selectedTasks.move(fromOffsets: source, toOffset: destination)
    }

    private func loadPlanData() {
        guard let plan = plan else { return }

        name = plan.name
        selectedTasks = plan.orderedTasks
        bonusPoints = plan.bonusPoints
        mode = plan.mode
        durationOverrides = plan.taskDurationOverrides

        if let start = plan.availableStartTime {
            startTime = start
        }
        if let end = plan.availableEndTime {
            endTime = end
        }
    }

    private func savePlan() {
        let planToSave = plan ?? TaskPlan(name: "", mode: mode)

        planToSave.name = name.trimmingCharacters(in: .whitespaces)
        planToSave.tasks = Array(Set(selectedTasks))  // SwiftData Relationship 需要去重
        planToSave.taskOrder = selectedTasks.map { $0.taskId }  // 完整顺序（含重复）
        planToSave.bonusPoints = bonusPoints
        planToSave.mode = mode
        planToSave.taskDurationOverrides = durationOverrides
        planToSave.availableStartTime = mode == "fixed" ? startTime : nil
        planToSave.availableEndTime = mode == "fixed" ? endTime : nil

        if plan == nil {
            modelContext.insert(planToSave)
        }

        dismiss()
    }
}

// MARK: - 任务行组件（带时长调整）

private struct TaskRowWithDuration: View {
    let task: TaskItem
    let duration: Int
    let onAdjust: (Int) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            TaskTypeIcon(task: task)

            VStack(alignment: .leading) {
                Text(task.name)
                Text(task.isRestTask ? "休息" : "学习")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            DurationStepper(
                duration: duration,
                onAdjust: onAdjust
            )

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
    }
}

// MARK: - 任务类型图标

private struct TaskTypeIcon: View {
    let task: TaskItem

    var body: some View {
        Image(systemName: task.isRestTask ? "gamecontroller" : "book")
            .foregroundStyle(task.isRestTask ? .green : .blue)
            .frame(width: 24)
    }
}

// MARK: - 时长微调器

private struct DurationStepper: View {
    let duration: Int
    let onAdjust: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button { onAdjust(-1) } label: {
                Image(systemName: "minus.circle")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.borderless)
            .disabled(duration <= 1)

            Text("\(duration)")
                .font(.body.monospacedDigit())
                .frame(minWidth: 30)

            Button { onAdjust(1) } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.borderless)

            Text("分钟")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 任务选择器

private struct TaskPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTasks: [TaskItem]
    let allTasks: [TaskItem]

    // 过滤掉模板，只显示普通任务
    private var availableTasks: [TaskItem] {
        allTasks.filter { !$0.isTemplate }
    }

    var body: some View {
        NavigationStack {
            List {
                // 上半部分：可选任务列表
                Section("选择任务") {
                    if availableTasks.isEmpty {
                        ContentUnavailableView(
                            "暂无可选任务",
                            systemImage: "checklist",
                            description: Text("请先在任务管理中创建任务")
                        )
                    } else {
                        ForEach(availableTasks) { task in
                            Button { addTask(task) } label: {
                                HStack {
                                    TaskTypeIcon(task: task)
                                    VStack(alignment: .leading) {
                                        Text(task.name)
                                        Text("\(task.durationMinutes) 分钟")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // 下半部分：已选中任务顺序
                Section("已选中任务顺序（\(selectedTasks.count) 个）") {
                    if selectedTasks.isEmpty {
                        Text("点击上方任务添加到计划")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(selectedTasks.enumerated()), id: \.offset) { index, task in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30)
                                TaskTypeIcon(task: task)
                                Text(task.name)
                                Spacer()
                                Button { removeTask(at: index) } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            }
            .navigationTitle("添加任务到计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addTask(_ task: TaskItem) {
        selectedTasks.append(task)
    }

    private func removeTask(at index: Int) {
        selectedTasks.remove(at: index)
    }
}

#Preview {
    PlanEditView()
        .modelContainer(for: TaskPlan.self, inMemory: true)
}
