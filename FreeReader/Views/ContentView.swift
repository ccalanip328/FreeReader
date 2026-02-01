import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var library: LibraryStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBar(query: $viewModel.query) {
                    Task { await viewModel.search() }
                }

                if viewModel.isLoading {
                    ProgressView("搜尋中...")
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }

                List {
                    if !library.favorites.isEmpty {
                        Section("收藏") {
                            ForEach(library.favorites) { favorite in
                                NavigationLink(favorite.title) {
                                    ChapterListView(
                                        novel: Novel(
                                            id: favorite.id,
                                            title: favorite.title,
                                            url: URL(string: favorite.url)!,
                                            author: nil,
                                            summary: nil
                                        )
                                    )
                                }
                            }
                        }
                    }

                    Section("搜尋結果") {
                        ForEach(viewModel.results) { novel in
                            NavigationLink(novel.title) {
                                ChapterListView(novel: novel)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .navigationTitle("Free Reader")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink("收藏") {
                        FavoritesView()
                    }
                    NavigationLink("設定") {
                        SettingsView()
                    }
                }
            }
        }
    }
}

private struct SearchBar: View {
    @Binding var query: String
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("輸入小說關鍵字", text: $query)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit(onSearch)

            Button("搜尋") {
                onSearch()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
