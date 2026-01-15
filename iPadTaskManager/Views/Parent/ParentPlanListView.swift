import SwiftUI
import SwiftData

/// 家长端：任务计划列表
struct ParentPlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskPlan.createdAt, order: .reverse) private var plans: [TaskPlan]

    @State private var showCreatePlan = false

    var body: some View {
        NavigationStack {
            Group {
                if plans.isEmpty {
                    ContentUnavailableView(
                        "暂无计划",
                        systemImage: "calendar.badge.plus",
                        description: Text("点击右上角 + 创建第一个任务计划")
                    )
                } else {
                    List {
                        ForEach(plans) { plan in
                            PlanRowView(plan: plan)
                        }
                        .onDelete(perform: deletePlans)
                    }
                }
            }
            .navigationTitle("任务计划")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreatePlan = true
                    } label: {
                        Label("新建计划", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreatePlan) {
                PlanEditView()
            }
        }
    }

    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(plans[index])
        }
    }
}

// MARK: - 计划行视图

private struct PlanRowView: View {
    let plan: TaskPlan
    @State private var showEdit = false

    var body: some View {
        Button {
            showEdit = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(plan.name)
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "list.number")
                        Text("\(plan.orderedTasks.count) 个任务")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                HStack {
                    Label("总时长 \(plan.totalDurationMinutes) 分钟", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.blue)

                    if plan.bonusPoints > 0 {
                        Label("奖励 \(plan.bonusPoints) 积分", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEdit) {
            PlanEditView(plan: plan)
        }
    }
}

#Preview {
    ParentPlanListView()
        .modelContainer(for: TaskPlan.self, inMemory: true)
}

// MARK: - 模板列表

/// 家长端：任务模板列表
struct ParentTemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { $0.isTemplate }, sort: \TaskItem.createdAt, order: .reverse)
    private var customTemplates: [TaskItem]

    @State private var selectedTemplate: TaskTemplate?
    @State private var selectedCustomTemplate: TaskItem?

    var body: some View {
        NavigationStack {
            List {
                // 预设模板
                Section("预设模板") {
                    ForEach(PresetTemplates.categories, id: \.self) { category in
                        DisclosureGroup(category) {
                            ForEach(PresetTemplates.grouped[category] ?? []) { template in
                                TemplateRowView(template: template)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTemplate = template
                                    }
                            }
                        }
                    }
                }

                // 自定义模板
                if !customTemplates.isEmpty {
                    Section("我的模板") {
                        ForEach(customTemplates) { template in
                            CustomTemplateRowView(template: template)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCustomTemplate = template
                                }
                        }
                        .onDelete(perform: deleteCustomTemplates)
                    }
                }
            }
            .navigationTitle("任务模板")
            .toolbar {
                if !customTemplates.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        EditButton()
                    }
                }
            }
            .sheet(item: $selectedTemplate) { template in
                TaskEditView(template: template)
            }
            .sheet(item: $selectedCustomTemplate) { template in
                TaskEditView(customTemplate: template)
            }
        }
    }

    private func deleteCustomTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(customTemplates[index])
        }
    }
}

// MARK: - 预设模板行视图

private struct TemplateRowView: View {
    let template: TaskTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.name)
                    .font(.body)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(template.durationMinutes)分钟")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text("\(template.pointsReward)")
                }
                .font(.caption)
                .foregroundStyle(.orange)
            }

            if !template.description.isEmpty {
                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if template.requiresScreenshot {
                Label("需要截图", systemImage: "camera")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 自定义模板行视图

private struct CustomTemplateRowView: View {
    let template: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(template.name)
                    .font(.body)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(template.durationMinutes)分钟")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                    Text("\(template.pointsReward)")
                }
                .font(.caption)
                .foregroundStyle(.orange)
            }

            if !template.taskDescription.isEmpty {
                Text(template.taskDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                if template.requiresScreenshot {
                    Label("需要截图", systemImage: "camera")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }

                if template.allowedAppTokens != nil {
                    Label("已指定应用", systemImage: "app.badge")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
