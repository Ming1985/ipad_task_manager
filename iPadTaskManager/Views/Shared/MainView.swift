import SwiftUI

/// 主视图：根据模式显示孩子或家长界面
struct MainView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.currentMode {
            case .child:
                ChildTabView()
            case .parent:
                ParentTabView()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppState())
}
