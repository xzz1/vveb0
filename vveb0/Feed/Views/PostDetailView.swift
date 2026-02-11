import SwiftUI

struct PostDetailView: View {
    let post: TimelinePost
    @ObservedObject var viewModel: TimelineViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PostCardView(post: currentPost, viewModel: viewModel)

                Text("评论")
                    .font(.headline)

                ForEach(0..<6, id: \.self) { idx in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 34, height: 34)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("用户\(idx + 1)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("这条内容不错，信息密度很高，交互细节也舒服。")
                                .font(.subheadline)
                            Text("\(idx + 2) 分钟前")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("正文")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentPost: TimelinePost {
        viewModel.posts.first(where: { $0.id == post.id }) ?? post
    }
}
