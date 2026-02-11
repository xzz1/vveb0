import SwiftUI

struct MessageView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @State private var accessToken: String

    init(viewModel: TimelineViewModel) {
        self.viewModel = viewModel
        _accessToken = State(initialValue: viewModel.storedAccessToken)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("开发调试") {
                    LabeledContent("数据源", value: viewModel.serviceName)

                    TextField("输入 API Token", text: $accessToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    HStack(spacing: 12) {
                        Button("保存 Token") {
                            viewModel.saveAccessToken(accessToken)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("清空 Token", role: .destructive) {
                            accessToken = ""
                            viewModel.clearAccessToken()
                        }
                        .buttonStyle(.bordered)
                    }

                    Button("刷新首页") {
                        Task { await viewModel.refresh() }
                    }

                    if !viewModel.lastErrorMessage.isEmpty {
                        Text(viewModel.lastErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("消息") {
                    Label("评论", systemImage: "message")
                    Label("@我的", systemImage: "at")
                    Label("赞和收藏", systemImage: "heart")
                    Label("私信", systemImage: "envelope")
                }
            }
            .navigationTitle("消息")
        }
    }
}

struct ProfileView: View {
    @ObservedObject var session: SessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color.red.opacity(0.18))
                            .frame(width: 70, height: 70)
                            .overlay {
                                Text("你")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.red)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.displayName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(session.handle)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 22) {
                        statColumn(title: "微博", value: "58")
                        statColumn(title: "关注", value: "193")
                        statColumn(title: "粉丝", value: "5.2k")
                    }

                    VStack(spacing: 0) {
                        profileRow("我的收藏")
                        Divider()
                        profileRow("浏览记录")
                        Divider()
                        profileRow("草稿箱")
                    }
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )

                    Button(role: .destructive) {
                        session.logout()
                    } label: {
                        Text("退出登录")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
            }
            .navigationTitle("我")
        }
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func profileRow(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
    }
}
