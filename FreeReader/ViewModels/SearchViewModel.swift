import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Novel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: HJWZWService

    init(service: HJWZWService = HJWZWService()) {
        self.service = service
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            results = try await service.search(query: trimmed)
            if results.isEmpty {
                errorMessage = "找不到相關結果"
            }
        } catch {
            errorMessage = "搜尋失敗，請稍後再試"
        }
        isLoading = false
    }
}
