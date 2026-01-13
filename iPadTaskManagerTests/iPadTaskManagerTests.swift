import XCTest
@testable import iPadTaskManager

final class iPadTaskManagerTests: XCTestCase {

    func testAppStateInitialValues() throws {
        let appState = AppState()

        XCTAssertEqual(appState.currentMode, .child)
        XCTAssertFalse(appState.isPasswordSet)
        XCTAssertFalse(appState.showPasswordPrompt)
        XCTAssertTrue(appState.isFirstLaunch)
    }

    func testAppStateModeSwitch() throws {
        let appState = AppState()

        // 初始为孩子模式
        XCTAssertEqual(appState.currentMode, .child)

        // 切换到家长模式
        appState.onPasswordVerified()
        XCTAssertEqual(appState.currentMode, .parent)

        // 切换回孩子模式
        appState.switchToChildMode()
        XCTAssertEqual(appState.currentMode, .child)
    }

    func testAppSettingsPoints() throws {
        let settings = AppSettings()

        XCTAssertEqual(settings.currentPoints, 0)

        settings.addPoints(100)
        XCTAssertEqual(settings.currentPoints, 100)

        let success = settings.spendPoints(30)
        XCTAssertTrue(success)
        XCTAssertEqual(settings.currentPoints, 70)

        let fail = settings.spendPoints(100)
        XCTAssertFalse(fail)
        XCTAssertEqual(settings.currentPoints, 70)
    }
}
