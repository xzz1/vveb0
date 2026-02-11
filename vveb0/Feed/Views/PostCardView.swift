import SwiftUI

struct PostCardView: View {
    let post: TimelinePost
    @ObservedObject var viewModel: TimelineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            Text(post.content)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if !post.imageNames.isEmpty {
                imageGrid
            }

            HStack(spacing: 16) {
                Text("\(post.publishTime) · \(post.source)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                actionButton(systemName: "arrow.2.squarepath", text: post.repostCount, active: post.reposted) {
                    viewModel.toggleRepost(postID: post.id)
                }

                actionButton(systemName: "message", text: post.commentCount, active: false) {}

                actionButton(systemName: post.liked ? "heart.fill" : "heart", text: post.likeCount, active: post.liked) {
                    viewModel.toggleLike(postID: post.id)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.red.opacity(0.18))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(post.user.name.prefix(1)))
                        .foregroundStyle(.red)
                        .fontWeight(.semibold)
                }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(post.user.name)
                        .fontWeight(.semibold)
                    if let badge = post.user.badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange.opacity(0.2)))
                            .foregroundStyle(.orange)
                    }
                }

                Text(post.user.handle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
        }
    }

    private var imageGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(post.imageNames.enumerated()), id: \.offset) { index, _ in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(height: 86)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                        Text("\(index + 1)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .offset(x: 24, y: 28)
                    }
            }
        }
    }

    private func actionButton(systemName: String, text: Int, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: systemName)
                Text("\(max(text, 0))")
            }
            .font(.caption)
            .foregroundStyle(active ? Color.red : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}
