import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]

    var body: some View {
        Group {
            if appState.isFirstLaunch {
                // 首次启动：设置密码
                SetupPasswordView()
            } else {
                // 正常使用
                MainView()
            }
        }
        .sheet(isPresented: $appState.showPasswordPrompt) {
            PasswordPromptView()
        }
        .onAppear {
            ensureSettingsExist()
        }
    }

    private func ensureSettingsExist() {
        if settingsArray.isEmpty {
            let settings = AppSettings()
            modelContext.insert(settings)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
