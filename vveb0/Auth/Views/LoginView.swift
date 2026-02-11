import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var session: SessionViewModel
    @State private var step: LoginStep = .phoneInput
    @State private var phoneNumber = ""
    @State private var smsCode = ""
    @State private var showConfirmAlert = false
    @State private var countdown = 58

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if step == .phoneInput {
                    phoneInputPage
                } else {
                    smsCodePage
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .alert("我们将发送验证码\n到下面的手机号：\n\(phoneNumber)", isPresented: $showConfirmAlert) {
                Button("取消", role: .cancel) {}
                Button("继续") {
                    step = .smsCode
                    smsCode = ""
                    countdown = 58
                }
            }
            .onReceive(timer) { _ in
                guard step == .smsCode, countdown > 0 else { return }
                countdown -= 1
            }
        }
    }
}

private extension LoginView {
    var phoneInputPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("输入手机号码")
                .font(.system(size: 42, weight: .bold))
                .padding(.top, 28)

            Text("未注册手机号验证通过后将自动注册")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, 14)

            HStack(spacing: 12) {
                Text("CN")
                    .foregroundStyle(.blue)
                    .font(.system(size: 18))
                Text("+86")
                    .font(.system(size: 18))

                TextField("手机号", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18))
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = String(newValue.filter(\.isNumber).prefix(11))
                    }
            }
            .padding(.top, 64)

            Divider()
                .padding(.top, 18)

            Button {
                showConfirmAlert = true
            } label: {
                Text("确定")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(canSubmitPhone ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(canSubmitPhone ? Color.orange : Color(.systemGray5))
                    )
            }
            .disabled(!canSubmitPhone)
            .padding(.top, 34)

            Spacer()
        }
    }

    var smsCodePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    step = .phoneInput
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                }
                Spacer()
            }

            Text("验证码已经发送到你的手机上")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 36)

            Text("输入我们发送至 \(phoneNumber) 的验证码")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, 14)

            TextField("短信验证码", text: $smsCode)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 88)
                .onChange(of: smsCode) { _, newValue in
                    smsCode = String(newValue.filter(\.isNumber).prefix(6))
                }

            Divider()
                .padding(.top, 14)

            Button {
                session.login(phone: phoneNumber)
            } label: {
                Text("确定")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(canSubmitCode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(canSubmitCode ? Color.orange : Color(.systemGray5))
                    )
            }
            .disabled(!canSubmitCode)
            .padding(.top, 30)

            Text("你将会在 \(countdown) 秒收到信息")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 48)

            Spacer()
        }
    }

    var canSubmitPhone: Bool {
        phoneNumber.count == 11
    }

    var canSubmitCode: Bool {
        smsCode.count == 6
    }

    var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}

private enum LoginStep {
    case phoneInput
    case smsCode
}
