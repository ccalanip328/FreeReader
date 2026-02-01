import Foundation

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published var contents: [ChapterContent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: HJWZWService
    private let chapters: [Chapter]
    private var loadedCount = 0

    init(chapters: [Chapter], service: HJWZWService = HJWZWService()) {
        self.chapters = chapters
        self.service = service
    }

    var hasMore: Bool {
        loadedCount < chapters.count
    }

    func loadInitial(chaptersPerLoad: Int) async {
        contents = []
        loadedCount = 0
        await loadMore(chaptersPerLoad: chaptersPerLoad)
    }

    func loadMore(chaptersPerLoad: Int) async {
        guard !isLoading else { return }
        guard loadedCount < chapters.count else { return }

        isLoading = true
        errorMessage = nil

        let end = min(loadedCount + max(chaptersPerLoad, 1), chapters.count)
        for index in loadedCount..<end {
            let chapter = chapters[index]
            do {
                let content = try await service.fetchChapterContent(chapter)
                contents.append(content)
            } catch {
                errorMessage = "載入章節失敗"
                break
            }
        }
        loadedCount = end
        isLoading = false
    }

    func lastLoadedChapter() -> Chapter? {
        guard let lastContent = contents.last else { return nil }
        return chapters.first { $0.id == lastContent.id }
    }
}
