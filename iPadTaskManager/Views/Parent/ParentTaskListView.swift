import SwiftUI
import SwiftData

/// 家长端：任务列表和管理
struct ParentTaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var showCreateTask = false
    @State private var taskToDelete: TaskItem?

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "暂无任务",
                        systemImage: "checklist",
                        description: Text("点击右上角 + 创建第一个任务")
                    )
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete(perform: confirmDelete)
                    }
                }
            }
            .navigationTitle("任务管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateTask = true
                    } label: {
                        Label("新建任务", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTask) {
                TaskEditView()
            }
            .alert("确认删除", isPresented: .init(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    guard let task = taskToDelete else { return }
                    modelContext.delete(task)
                }
            } message: {
                Text("确定要删除任务「\(taskToDelete?.name ?? "")」吗？此操作无法撤销。")
            }
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        if let first = offsets.first {
            taskToDelete = tasks[first]
        }
    }
}

// MARK: - 任务行视图

private struct TaskRowView: View {
    let task: TaskItem
    @State private var showEdit = false

    var body: some View {
        Button {
            showEdit = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.name)
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(task.durationMinutes)分钟")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Label("\(task.pointsReward) 积分", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    if task.requiresScreenshot {
                        Label("需要截图", systemImage: "camera")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEdit) {
            TaskEditView(task: task)
        }
    }
}

#Preview {
    ParentTaskListView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
