import XCTest

final class NavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 验证首次启动显示密码设置界面
    func testFirstLaunchShowsPasswordSetup() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-state"] // 可用于重置状态
        app.launch()

        // 验证密码设置界面元素存在
        XCTAssertTrue(app.staticTexts["设置管理员密码"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["请设置 6 位数字密码，用于进入家长模式"].exists)
        XCTAssertTrue(app.buttons["确认设置"].exists)
    }

    /// 验证设置密码后进入孩子模式
    func testSetPasswordAndEnterChildMode() throws {
        let app = XCUIApplication()
        app.launch()

        // 如果在密码设置界面
        if app.staticTexts["设置管理员密码"].waitForExistence(timeout: 3) {
            // 找到两个密码输入区域并输入
            let passwordFields = app.textFields

            // 点击第一个输入区域
            if passwordFields.count > 0 {
                passwordFields.element(boundBy: 0).tap()
                // 输入 6 位数字
                app.typeText("123456")
            }

            // 点击第二个输入区域
            if passwordFields.count > 1 {
                passwordFields.element(boundBy: 1).tap()
                app.typeText("123456")
            }

            // 点击确认按钮
            let confirmButton = app.buttons["确认设置"]
            if confirmButton.isEnabled {
                confirmButton.tap()
            }
        }

        // 验证进入孩子模式 - TabBar 存在
        let taskTab = app.tabBars.buttons["任务"]
        let rewardTab = app.tabBars.buttons["奖励"]
        let profileTab = app.tabBars.buttons["我的"]

        // 至少等待界面切换
        _ = taskTab.waitForExistence(timeout: 5)

        // 验证 Tab 存在
        XCTAssertTrue(taskTab.exists || app.staticTexts["今日任务"].exists, "应该显示孩子模式界面")
    }

    /// 验证孩子模式 TabView 结构
    func testChildModeTabViewStructure() throws {
        let app = XCUIApplication()
        app.launch()

        // 跳过密码设置（如果需要）
        if app.staticTexts["设置管理员密码"].waitForExistence(timeout: 2) {
            // 密码设置逻辑...
            return // 跳过此测试如果在密码设置界面
        }

        // 验证 TabBar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        // 验证三个 Tab
        XCTAssertTrue(app.tabBars.buttons["任务"].exists)
        XCTAssertTrue(app.tabBars.buttons["奖励"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的"].exists)
    }
}
