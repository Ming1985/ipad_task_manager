import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

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
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
