import SwiftUI

struct ReaderView: View {
    let novel: Novel
    let chapters: [Chapter]

    @EnvironmentObject private var settings: ReaderSettings
    @EnvironmentObject private var library: LibraryStore
    @StateObject private var viewModel: ReaderViewModel

    init(novel: Novel, chapters: [Chapter]) {
        self.novel = novel
        self.chapters = chapters
        _viewModel = StateObject(wrappedValue: ReaderViewModel(chapters: chapters))
    }

    var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.contents) { content in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(content.title)
                                .font(.system(size: CGFloat(settings.fontSize) + 2, weight: .semibold))
                                .foregroundColor(settings.textColor)

                            Text(content.content)
                                .font(.system(size: CGFloat(settings.fontSize)))
                                .foregroundColor(settings.textColor)
                                .lineSpacing(6)
                        }
                        .padding(.bottom, 8)
                    }

                    if viewModel.isLoading {
                        ProgressView("載入中...")
                            .frame(maxWidth: .infinity)
                    } else if viewModel.hasMore {
                        Button("載入更多章節") {
                            Task { await viewModel.loadMore(chaptersPerLoad: settings.chaptersPerLoad) }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                    }

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(novel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("加書籤") {
                    if let last = viewModel.lastLoadedChapter() {
                        library.addBookmark(novel: novel, chapter: last)
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitial(chaptersPerLoad: settings.chaptersPerLoad)
            if let last = viewModel.lastLoadedChapter() {
                library.updateProgress(novel: novel, chapter: last)
            }
        }
        .onChange(of: viewModel.contents) { _ in
            if let last = viewModel.lastLoadedChapter() {
                library.updateProgress(novel: novel, chapter: last)
            }
        }
    }
}
