import XCTest

final class NavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 验证首次启动显示密码设置界面（或孩子模式界面）
    func testFirstLaunchShowsPasswordSetup() throws {
        let app = XCUIApplication()
        app.launch()

        // 等待界面加载
        sleep(2)

        // 验证显示密码设置界面或孩子模式界面
        let passwordSetupExists = app.staticTexts["设置管理员密码"].waitForExistence(timeout: 3)
        let childModeExists = app.tabBars.buttons["任务"].waitForExistence(timeout: 3)

        XCTAssertTrue(passwordSetupExists || childModeExists,
                     "应该显示密码设置界面或孩子模式界面")

        // 如果在密码设置界面，验证元素存在
        if passwordSetupExists {
            XCTAssertTrue(app.staticTexts["请设置 6 位数字密码，用于进入家长模式"].exists)
            XCTAssertTrue(app.buttons["下一步"].exists)
        }
    }

    /// 验证孩子模式界面结构（如果已设置密码）
    func testChildModeInterface() throws {
        let app = XCUIApplication()
        app.launch()

        // 如果在密码设置界面，跳过测试
        if app.staticTexts["设置管理员密码"].waitForExistence(timeout: 3) {
            // 密码未设置，跳过孩子模式测试
            return
        }

        // 验证孩子模式 TabBar
        let taskTab = app.tabBars.buttons["任务"]
        let rewardTab = app.tabBars.buttons["奖励"]
        let profileTab = app.tabBars.buttons["我的"]

        XCTAssertTrue(taskTab.waitForExistence(timeout: 5))
        XCTAssertTrue(taskTab.exists)
        XCTAssertTrue(rewardTab.exists)
        XCTAssertTrue(profileTab.exists)
    }

    /// 验证密码设置界面的步骤指示器
    func testPasswordSetupStepIndicator() throws {
        let app = XCUIApplication()
        app.launch()

        // 只在密码设置界面测试
        guard app.staticTexts["设置管理员密码"].waitForExistence(timeout: 3) else {
            return // 已设置密码，跳过
        }

        // 验证步骤指示器
        XCTAssertTrue(app.staticTexts["密码"].exists)
        XCTAssertTrue(app.staticTexts["安全问题"].exists)
    }
}
