import Foundation

struct TimelineUser: Identifiable, Hashable {
    let id: UUID
    let name: String
    let handle: String
    let badge: String?
    let isSpecialFollow: Bool

    init(id: UUID = UUID(), name: String, handle: String, badge: String? = nil, isSpecialFollow: Bool = false) {
        self.id = id
        self.name = name
        self.handle = handle
        self.badge = badge
        self.isSpecialFollow = isSpecialFollow
    }
}

struct TimelinePost: Identifiable, Hashable {
    let id: UUID
    let user: TimelineUser
    let content: String
    let publishTime: String
    let source: String
    let imageNames: [String]
    var liked: Bool
    var reposted: Bool
    var likeCount: Int
    var repostCount: Int
    var commentCount: Int

    init(
        id: UUID = UUID(),
        user: TimelineUser,
        content: String,
        publishTime: String,
        source: String,
        imageNames: [String] = [],
        liked: Bool = false,
        reposted: Bool = false,
        likeCount: Int,
        repostCount: Int,
        commentCount: Int
    ) {
        self.id = id
        self.user = user
        self.content = content
        self.publishTime = publishTime
        self.source = source
        self.imageNames = imageNames
        self.liked = liked
        self.reposted = reposted
        self.likeCount = likeCount
        self.repostCount = repostCount
        self.commentCount = commentCount
    }
}
