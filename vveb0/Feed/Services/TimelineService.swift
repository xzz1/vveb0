import Foundation

struct TimelinePage {
    let items: [TimelinePost]
    let hasMore: Bool
}

enum TimelineServiceError: LocalizedError {
    case invalidURL
    case unauthorized
    case notConfigured(String)
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "请求地址无效"
        case .unauthorized:
            return "未登录或 token 已失效"
        case .notConfigured(let message):
            return message
        case .invalidResponse:
            return "服务器响应无效"
        case .serverError(let message):
            return "接口错误: \(message)"
        }
    }
}

protocol TimelineServiceProtocol {
    var serviceName: String { get }
    func fetchHomeTimeline(page: Int, pageSize: Int, scope: FollowScope) async throws -> TimelinePage
}

final class MockTimelineService: TimelineServiceProtocol {
    var serviceName: String { "Mock" }

    func fetchHomeTimeline(page: Int, pageSize: Int, scope: FollowScope) async throws -> TimelinePage {
        try? await Task.sleep(nanoseconds: 350_000_000)

        let users = [
            TimelineUser(name: "雪川", handle: "@xuechuan", badge: "V", isSpecialFollow: true),
            TimelineUser(name: "像素茶馆", handle: "@pixeltea", isSpecialFollow: false),
            TimelineUser(name: "阿澈", handle: "@archer", badge: "V", isSpecialFollow: true)
        ]

        let items = (0..<pageSize).map { idx in
            let user = users[(idx + page) % users.count]
            let imageCount = ((idx + page) % 4 == 0) ? 3 : (((idx + page) % 3 == 0) ? 1 : 0)
            return TimelinePost(
                user: user,
                content: "第 \(page + 1) 页动态 \(idx + 1)：协议化接口层已接好，后续可直接替换成真实后端。",
                publishTime: "\(8 + idx) 分钟前",
                source: "vveb0 iPhone",
                imageNames: Array(repeating: "photo", count: imageCount),
                likeCount: 20 + idx + page * 2,
                repostCount: 3 + idx,
                commentCount: 5 + idx
            )
        }

        let filtered: [TimelinePost]
        switch scope {
        case .all:
            filtered = items
        case .special:
            filtered = items.filter { $0.user.isSpecialFollow }
        }

        return TimelinePage(items: filtered, hasMore: page < 8)
    }
}

final class BackendTimelineService: TimelineServiceProtocol {
    var serviceName: String { "Backend" }

    private let baseURL: URL
    private let tokenStore: AuthTokenStoreProtocol
    private let session: URLSession

    init(baseURL: URL, tokenStore: AuthTokenStoreProtocol, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.session = session
    }

    func fetchHomeTimeline(page: Int, pageSize: Int, scope: FollowScope) async throws -> TimelinePage {
        guard let token = tokenStore.accessToken, !token.isEmpty else {
            throw TimelineServiceError.unauthorized
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("timeline/home"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
            URLQueryItem(name: "scope", value: scope == .special ? "special" : "all")
        ]

        guard let url = components?.url else {
            throw TimelineServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw TimelineServiceError.invalidResponse
        }

        guard http.statusCode != 401 else {
            throw TimelineServiceError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            throw TimelineServiceError.serverError(String(data: data, encoding: .utf8) ?? "unknown")
        }

        let decoded = try JSONDecoder().decode(BackendTimelineResponse.self, from: data)
        let posts = decoded.items.map { item in
            TimelinePost(
                user: TimelineUser(
                    id: UUID(),
                    name: item.user.name,
                    handle: item.user.handle,
                    badge: item.user.badge,
                    isSpecialFollow: item.user.isSpecialFollow
                ),
                content: item.content,
                publishTime: item.publishTime,
                source: item.source,
                imageNames: item.imageNames,
                liked: item.liked,
                reposted: item.reposted,
                likeCount: item.likeCount,
                repostCount: item.repostCount,
                commentCount: item.commentCount
            )
        }

        return TimelinePage(items: posts, hasMore: decoded.hasMore)
    }
}

private struct BackendTimelineResponse: Decodable {
    let items: [BackendTimelineItem]
    let hasMore: Bool
}

private struct BackendTimelineItem: Decodable {
    let content: String
    let publishTime: String
    let source: String
    let imageNames: [String]
    let liked: Bool
    let reposted: Bool
    let likeCount: Int
    let repostCount: Int
    let commentCount: Int
    let user: BackendTimelineUser
}

private struct BackendTimelineUser: Decodable {
    let name: String
    let handle: String
    let badge: String?
    let isSpecialFollow: Bool
}
