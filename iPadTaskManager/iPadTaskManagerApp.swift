import SwiftUI
import SwiftData

@main
struct iPadTaskManagerApp: App {
    @StateObject private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            TaskPlan.self,
            TaskSession.self,
            Reward.self,
            PointTransaction.self,
            Screenshot.self,
            AppUsageLog.self,
            AppSettings.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(sharedModelContainer)
        }
    }
}
