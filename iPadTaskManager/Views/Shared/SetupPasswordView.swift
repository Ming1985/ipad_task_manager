import SwiftUI

/// 首次启动：设置管理员密码
struct SetupPasswordView: View {
    @EnvironmentObject private var appState: AppState

    /// 设置步骤
    enum Step {
        case password      // 设置密码
        case securityQuestion  // 设置安全问题
    }

    @State private var currentStep: Step = .password
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedQuestion = 0
    @State private var securityAnswer = ""
    @State private var showError = false
    @State private var errorMessage = ""

    /// 预设安全问题
    private let securityQuestions = [
        "您的第一只宠物叫什么名字？",
        "您母亲的姓名是什么？",
        "您最喜欢的老师叫什么？",
        "您出生的城市是哪里？",
        "您小学的名称是什么？"
    ]

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // 步骤指示器
            HStack(spacing: 8) {
                StepIndicator(number: 1, title: "密码", isActive: currentStep == .password, isCompleted: currentStep == .securityQuestion)
                Rectangle()
                    .fill(currentStep == .securityQuestion ? AppColors.primary : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 2)
                StepIndicator(number: 2, title: "安全问题", isActive: currentStep == .securityQuestion, isCompleted: false)
            }
            .padding(.horizontal, 40)

            // 内容区域
            switch currentStep {
            case .password:
                passwordStepView
            case .securityQuestion:
                securityQuestionStepView
            }

            Spacer()
        }
        .padding()
        .background(AppColors.childBackground)
    }

    // MARK: - 密码设置步骤

    private var passwordStepView: some View {
        VStack(spacing: 32) {
            // 图标和标题
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primary)

                Text("设置管理员密码")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("请设置 6 位数字密码，用于进入家长模式")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 密码输入
            VStack(spacing: 24) {
                PasswordField(title: "输入密码", text: $password)
                PasswordField(title: "确认密码", text: $confirmPassword)
            }
            .frame(maxWidth: 400)

            // 错误提示
            if showError {
                ErrorText(message: errorMessage)
            }

            // 下一步按钮
            Button {
                validatePasswordAndNext()
            } label: {
                Text("下一步")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(password.count != 6 || confirmPassword.count != 6)
        }
    }

    // MARK: - 安全问题设置步骤

    private var securityQuestionStepView: some View {
        VStack(spacing: 32) {
            // 图标和标题
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primary)

                Text("设置安全问题")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("用于忘记密码时重置")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // 问题选择
            VStack(alignment: .leading, spacing: 16) {
                Text("选择安全问题")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Picker("安全问题", selection: $selectedQuestion) {
                    ForEach(0..<securityQuestions.count, id: \.self) { index in
                        Text(securityQuestions[index]).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("您的答案")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("输入答案", text: $securityAnswer)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxWidth: 400)

            // 错误提示
            if showError {
                ErrorText(message: errorMessage)
            }

            // 按钮组
            HStack(spacing: 16) {
                Button {
                    currentStep = .password
                    showError = false
                } label: {
                    Text("上一步")
                        .font(.title3)
                        .frame(maxWidth: 140)
                        .padding()
                }
                .buttonStyle(.bordered)

                Button {
                    saveAndComplete()
                } label: {
                    Text("完成设置")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 140)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(securityAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - 逻辑方法

    private func validatePasswordAndNext() {
        showError = false

        if let error = PasswordValidation.validateNewPassword(password, confirm: confirmPassword) {
            errorMessage = error
            showError = true
            return
        }

        withAnimation { currentStep = .securityQuestion }
    }

    private func saveAndComplete() {
        showError = false

        let answer = securityAnswer.trimmingCharacters(in: .whitespaces)
        guard !answer.isEmpty else {
            errorMessage = "请输入安全问题答案"
            showError = true
            return
        }

        // 保存密码
        guard KeychainService.savePassword(password) else {
            errorMessage = "保存密码失败，请重试"
            showError = true
            return
        }

        // 保存安全问题
        let question = securityQuestions[selectedQuestion]
        guard KeychainService.saveSecurityQuestion(question, answer: answer) else {
            errorMessage = "保存安全问题失败，请重试"
            showError = true
            return
        }

        // 完成设置
        appState.onPasswordSet()
    }
}

// MARK: - 步骤指示器

private struct StepIndicator: View {
    let number: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive || isCompleted ? AppColors.primary : Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                } else {
                    Text("\(number)")
                        .foregroundStyle(isActive ? .white : .gray)
                        .fontWeight(.bold)
                }
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(isActive || isCompleted ? AppColors.primary : .gray)
        }
    }
}

// MARK: - 密码输入框

struct PasswordField: View {
    let title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            ZStack {
                // 隐藏的输入框
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0.01)
                    .onChange(of: text) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        text = String(filtered.prefix(6))
                    }

                // 可视化圆点
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index < text.count ? AppColors.primary : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? AppColors.primary : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                isFocused = true
            }
        }
    }
}

#Preview {
    SetupPasswordView()
        .environmentObject(AppState())
}
