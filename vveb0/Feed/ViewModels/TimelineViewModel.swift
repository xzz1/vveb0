import Foundation
import Combine

enum FollowScope: String, CaseIterable {
    case all = "全部关注"
    case special = "特别关注"
}

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published private(set) var posts: [TimelinePost] = []
    @Published private(set) var isLoadingMore = false
    @Published var lastErrorMessage = ""
    @Published private(set) var currentScope: FollowScope = .all

    private var currentPage = 0
    private var hasMore = true
    private let pageSize = 20
    private let timelineService: TimelineServiceProtocol
    private let tokenStore: AuthTokenStoreProtocol

    init(
        timelineService: TimelineServiceProtocol = MockTimelineService(),
        tokenStore: AuthTokenStoreProtocol = UserDefaultsTokenStore()
    ) {
        self.timelineService = timelineService
        self.tokenStore = tokenStore
    }

    func refresh() async {
        currentPage = 0
        hasMore = true
        await fetchPage(reset: true)
    }

    func posts(for scope: FollowScope) -> [TimelinePost] {
        switch scope {
        case .all:
            return posts
        case .special:
            return posts.filter { $0.user.isSpecialFollow }
        }
    }

    func applyScope(_ scope: FollowScope) async {
        currentScope = scope
        await refresh()
    }

    func loadMoreIfNeeded(currentItem item: TimelinePost?, scope: FollowScope) async {
        currentScope = scope

        guard hasMore else { return }

        let visiblePosts = posts(for: scope)
        guard let item,
              let last = visiblePosts.last,
              item.id == last.id,
              !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }
        currentPage += 1
        await fetchPage(reset: false)
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

        let me = TimelineUser(name: "你", handle: "@me", isSpecialFollow: true)
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

    var serviceName: String {
        timelineService.serviceName
    }

    var storedAccessToken: String {
        tokenStore.accessToken ?? ""
    }

    func saveAccessToken(_ token: String) {
        tokenStore.accessToken = token
    }

    func clearAccessToken() {
        tokenStore.accessToken = nil
    }

    private func fetchPage(reset: Bool) async {
        do {
            let page = try await timelineService.fetchHomeTimeline(
                page: currentPage,
                pageSize: pageSize,
                scope: currentScope
            )
            if reset {
                posts = page.items
            } else {
                posts.append(contentsOf: page.items)
            }
            hasMore = page.hasMore
            lastErrorMessage = ""
        } catch {
            lastErrorMessage = error.localizedDescription
            if !reset, currentPage > 0 {
                currentPage -= 1
            }
        }
    }
}
