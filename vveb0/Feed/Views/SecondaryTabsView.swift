import SwiftUI

struct DiscoveryView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(1..<10, id: \.self) { idx in
                    HStack {
                        Text("热搜 \(idx)")
                        Spacer()
                        Text("\(idx * 10)万")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("发现")
        }
    }
}

struct MessageView: View {
    var body: some View {
        NavigationStack {
            List {
                Label("评论", systemImage: "message")
                Label("@我的", systemImage: "at")
                Label("赞和收藏", systemImage: "heart")
                Label("私信", systemImage: "envelope")
            }
            .navigationTitle("消息")
        }
    }
}

struct ProfileView: View {
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
                            Text("你的昵称")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("@me")
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
