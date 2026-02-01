import Foundation
import SwiftSoup

final class HJWZWService {
    private let baseURL = URL(string: "https://tw.hjwzw.com")!
    private let session: URLSession
    private let cacheStore: CacheStore

    init(session: URLSession = .shared, cacheStore: CacheStore = CacheStore()) {
        self.session = session
        self.cacheStore = cacheStore
    }

    func search(query: String) async throws -> [Novel] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
        let url = baseURL.appendingPathComponent("List").appendingPathComponent(encoded)
        let html = try await loadHTML(from: url)
        return try parseSearchResults(html: html)
    }

    func fetchChapters(bookId: String) async throws -> [Chapter] {
        let url = baseURL.appendingPathComponent("Book/Chapter/\(bookId)")
        let html = try await loadHTML(from: url)
        return try parseChapters(html: html)
    }

    func fetchChapterContent(_ chapter: Chapter) async throws -> ChapterContent {
        if let cached = cacheStore.getContent(for: chapter.url) {
            return ChapterContent(id: chapter.id, title: chapter.title, content: cached, sourceURL: chapter.url)
        }

        let html = try await loadHTML(from: chapter.url)
        let content = try HTMLTextExtractor.extractMainText(from: html, title: chapter.title)
        cacheStore.saveContent(content, for: chapter.url)
        return ChapterContent(id: chapter.id, title: chapter.title, content: content, sourceURL: chapter.url)
    }

    private func loadHTML(from url: URL) async throws -> String {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        let (data, _) = try await session.data(for: request)
        return String(decoding: data, as: UTF8.self)
    }

    private func parseSearchResults(html: String) throws -> [Novel] {
        let document = try SwiftSoup.parse(html)
        let anchors = try document.select("a[href^=/Book/]")
        var seen = Set<String>()
        var results: [Novel] = []

        for anchor in anchors.array() {
            let href = try anchor.attr("href")
            if href.contains("/Book/Read/") || href.contains("/Book/Chapter/") {
                continue
            }
            guard let url = URL(string: href, relativeTo: baseURL)?.absoluteURL else { continue }
            let title = try anchor.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if title.isEmpty { continue }

            let id = url.lastPathComponent
            let key = "\(id)|\(title)"
            if seen.contains(key) { continue }
            seen.insert(key)

            let novel = Novel(id: id, title: title, url: url, author: nil, summary: nil)
            results.append(novel)
            if results.count >= 60 { break }
        }

        return results
    }

    private func parseChapters(html: String) throws -> [Chapter] {
        let document = try SwiftSoup.parse(html)
        let anchors = try document.select("a[href^=/Book/Read/]")
        var seen = Set<String>()
        var chapters: [Chapter] = []

        for anchor in anchors.array() {
            let href = try anchor.attr("href")
            guard let url = URL(string: href, relativeTo: baseURL)?.absoluteURL else { continue }
            let title = try anchor.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if title.isEmpty { continue }
            let id = url.path + (url.query ?? "")
            if seen.contains(id) { continue }
            seen.insert(id)
            chapters.append(Chapter(id: id, title: title, url: url))
        }

        return chapters
    }
}
