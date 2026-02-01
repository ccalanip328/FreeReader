import SwiftUI

struct ChapterListView: View {
    let novel: Novel
    @StateObject private var viewModel: ChapterListViewModel
    @EnvironmentObject private var library: LibraryStore
    @State private var showBookmarks = false

    init(novel: Novel) {
        self.novel = novel
        _viewModel = StateObject(wrappedValue: ChapterListViewModel(novel: novel))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("載入章節中...")
            } else if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundColor(.secondary)
            } else {
                List {
                    if let progress = library.progress(for: novel.id),
                       let index = viewModel.chapters.firstIndex(where: { $0.id == progress.chapterId }) {
                        Section("繼續閱讀") {
                            NavigationLink(progress.chapterTitle) {
                                ReaderView(
                                    novel: novel,
                                    chapters: Array(viewModel.chapters[index...])
                                )
                            }
                        }
                    }

                    Section("章節列表") {
                        ForEach(viewModel.chapters.indices, id: \.self) { index in
                            let chapter = viewModel.chapters[index]
                            NavigationLink(chapter.title) {
                                ReaderView(
                                    novel: novel,
                                    chapters: Array(viewModel.chapters[index...])
                                )
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(novel.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(library.isFavorite(novel) ? "取消收藏" : "收藏") {
                    library.toggleFavorite(novel)
                }
                Button("書籤") {
                    showBookmarks = true
                }
            }
        }
        .sheet(isPresented: $showBookmarks) {
            NavigationStack {
                BookmarksView(novel: novel, chapters: viewModel.chapters)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
