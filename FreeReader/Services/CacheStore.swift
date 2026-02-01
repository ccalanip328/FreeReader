import Foundation
import CryptoKit

final class CacheStore {
    private let fileManager = FileManager.default
    private let baseURL: URL

    init(folderName: String = "FreeReaderCache") {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        baseURL = caches.appendingPathComponent(folderName, isDirectory: true)
        if !fileManager.fileExists(atPath: baseURL.path) {
            try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        }
    }

    func getContent(for url: URL) -> String? {
        let path = cacheFileURL(for: url)
        guard fileManager.fileExists(atPath: path.path) else { return nil }
        return try? String(contentsOf: path, encoding: .utf8)
    }

    func saveContent(_ content: String, for url: URL) {
        let path = cacheFileURL(for: url)
        try? content.write(to: path, atomically: true, encoding: .utf8)
    }

    private func cacheFileURL(for url: URL) -> URL {
        let key = url.absoluteString
        let hash = SHA256.hash(data: Data(key.utf8))
        let filename = hash.compactMap { String(format: "%02x", $0) }.joined()
        return baseURL.appendingPathComponent(filename + ".txt")
    }
}
