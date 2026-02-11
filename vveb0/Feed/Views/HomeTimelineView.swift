import SwiftUI

struct HomeTimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @Binding var showComposer: Bool

    @State private var selectedChannel: HomeChannel = .recommended

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.posts) { post in
                    NavigationLink {
                        PostDetailView(post: post, viewModel: viewModel)
                    } label: {
                        PostCardView(post: post, viewModel: viewModel)
                            .task {
                                await viewModel.loadMoreIfNeeded(currentItem: post)
                            }
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                }

                if viewModel.isLoadingMore {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("加载更多...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("首页")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("频道", selection: $selectedChannel) {
                        ForEach(HomeChannel.allCases, id: \.self) { channel in
                            Text(channel.rawValue).tag(channel)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showComposer = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

enum HomeChannel: String, CaseIterable {
    case following = "关注"
    case recommended = "推荐"
}
