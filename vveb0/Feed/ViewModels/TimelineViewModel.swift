import Foundation
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published private(set) var posts: [TimelinePost] = []
    @Published private(set) var isLoadingMore = false

    private var page = 0

    init() {
        posts = Self.mockPosts(page: 0)
    }

    func refresh() async {
        try? await Task.sleep(nanoseconds: 700_000_000)
        page = 0
        posts = Self.mockPosts(page: 0)
    }

    func loadMoreIfNeeded(currentItem item: TimelinePost?) async {
        guard let item,
              let last = posts.last,
              item.id == last.id,
              !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        try? await Task.sleep(nanoseconds: 600_000_000)
        page += 1
        posts.append(contentsOf: Self.mockPosts(page: page))
    }

    func toggleLike(postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].liked.toggle()
        posts[index].likeCount += posts[index].liked ? 1 : -1
    }

    func toggleRepost(postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].reposted.toggle()
        posts[index].repostCount += posts[index].reposted ? 1 : -1
    }

    func publish(content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let me = TimelineUser(name: "你", handle: "@me")
        let newPost = TimelinePost(
            user: me,
            content: trimmed,
            publishTime: "刚刚",
            source: "iPhone 客户端",
            likeCount: 0,
            repostCount: 0,
            commentCount: 0
        )
        posts.insert(newPost, at: 0)
    }

    private static func mockPosts(page: Int) -> [TimelinePost] {
        let users = [
            TimelineUser(name: "雪川", handle: "@xuechuan", badge: "V"),
            TimelineUser(name: "像素茶馆", handle: "@pixeltea"),
            TimelineUser(name: "阿澈", handle: "@archer", badge: "V")
        ]

        return (0..<10).map { idx in
            let user = users[(idx + page) % users.count]
            let imageCount = ((idx + page) % 4 == 0) ? 3 : (((idx + page) % 3 == 0) ? 1 : 0)
            return TimelinePost(
                user: user,
                content: "第 \(page + 1) 页动态 \(idx + 1)：今天把列表交互打磨了一遍，滚动时信息密度更高，阅读也更顺手。",
                publishTime: "\(8 + idx) 分钟前",
                source: "iPhone 17 Pro",
                imageNames: Array(repeating: "photo", count: imageCount),
                likeCount: 20 + idx + page * 2,
                repostCount: 3 + idx,
                commentCount: 5 + idx
            )
        }
    }
}
