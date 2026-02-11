import SwiftUI

struct HomeTimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @Binding var showComposer: Bool

    @State private var selectedScope: FollowScope = .all

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.posts(for: selectedScope)) { post in
                    NavigationLink {
                        PostDetailView(post: post, viewModel: viewModel)
                    } label: {
                        PostCardView(post: post, viewModel: viewModel)
                            .task {
                                await viewModel.loadMoreIfNeeded(currentItem: post, scope: selectedScope)
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
            .task {
                if viewModel.posts(for: selectedScope).isEmpty {
                    await viewModel.applyScope(selectedScope)
                }
            }
            .onChange(of: selectedScope) { _, newScope in
                Task {
                    await viewModel.applyScope(newScope)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("首页")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(FollowScope.allCases, id: \.self) { scope in
                            Button {
                                selectedScope = scope
                            } label: {
                                if selectedScope == scope {
                                    Label(scope.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(scope.rawValue)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedScope.rawValue)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
