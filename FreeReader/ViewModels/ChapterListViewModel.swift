import Foundation

@MainActor
final class ChapterListViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: HJWZWService
    private let novel: Novel

    init(novel: Novel, service: HJWZWService = HJWZWService()) {
        self.novel = novel
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            chapters = try await service.fetchChapters(bookId: novel.id)
            if chapters.isEmpty {
                errorMessage = "章節列表為空"
            }
        } catch {
            errorMessage = "載入章節失敗"
        }
        isLoading = false
    }
}
