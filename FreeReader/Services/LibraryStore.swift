import Foundation

@MainActor
final class LibraryStore: ObservableObject {
    private enum Keys {
        static let favorites = "favorites"
        static let bookmarks = "bookmarks"
        static let progress = "reading_progress"
    }

    @Published private(set) var favorites: [Favorite] = []
    @Published private(set) var bookmarks: [Bookmark] = []
    @Published private(set) var progress: [ReadingProgress] = []

    init() {
        favorites = load(key: Keys.favorites) ?? []
        bookmarks = load(key: Keys.bookmarks) ?? []
        progress = load(key: Keys.progress) ?? []
    }

    func isFavorite(_ novel: Novel) -> Bool {
        favorites.contains { $0.id == novel.id }
    }

    func toggleFavorite(_ novel: Novel) {
        if isFavorite(novel) {
            favorites.removeAll { $0.id == novel.id }
        } else {
            favorites.append(Favorite(id: novel.id, title: novel.title, url: novel.url.absoluteString))
        }
        save(favorites, key: Keys.favorites)
    }

    func addBookmark(novel: Novel, chapter: Chapter) {
        let bookmark = Bookmark(
            id: UUID().uuidString,
            novelId: novel.id,
            novelTitle: novel.title,
            chapterId: chapter.id,
            chapterTitle: chapter.title,
            chapterURL: chapter.url.absoluteString,
            createdAt: Date()
        )
        bookmarks.insert(bookmark, at: 0)
        save(bookmarks, key: Keys.bookmarks)
    }

    func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        save(bookmarks, key: Keys.bookmarks)
    }

    func bookmarks(for novelId: String) -> [Bookmark] {
        bookmarks.filter { $0.novelId == novelId }
    }

    func updateProgress(novel: Novel, chapter: Chapter) {
        let newProgress = ReadingProgress(
            id: novel.id,
            novelId: novel.id,
            novelTitle: novel.title,
            chapterId: chapter.id,
            chapterTitle: chapter.title,
            chapterURL: chapter.url.absoluteString,
            updatedAt: Date()
        )

        if let index = progress.firstIndex(where: { $0.novelId == novel.id }) {
            progress[index] = newProgress
        } else {
            progress.append(newProgress)
        }
        save(progress, key: Keys.progress)
    }

    func progress(for novelId: String) -> ReadingProgress? {
        progress.first { $0.novelId == novelId }
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }
}
