import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @State private var selectedTab: RootTab = .home
    @State private var showComposer = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeTimelineView(viewModel: viewModel, showComposer: $showComposer)
                    .tabItem { Label("首页", systemImage: "house") }
                    .tag(RootTab.home)

                DiscoveryView()
                    .tabItem { Label("发现", systemImage: "safari") }
                    .tag(RootTab.discovery)

                MessageView()
                    .tabItem { Label("消息", systemImage: "bubble.left.and.bubble.right") }
                    .tag(RootTab.message)

                ProfileView()
                    .tabItem { Label("我", systemImage: "person") }
                    .tag(RootTab.profile)
            }
            .tint(.red)

            if selectedTab == .home {
                Button {
                    showComposer = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(Circle().fill(Color.red))
                        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 86)
                .accessibilityLabel("发布")
            }
        }
        .sheet(isPresented: $showComposer) {
            ComposePostView { content in
                viewModel.publish(content: content)
            }
        }
    }
}

enum RootTab: Hashable {
    case home
    case discovery
    case message
    case profile
}
