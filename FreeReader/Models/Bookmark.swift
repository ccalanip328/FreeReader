import Foundation

struct Bookmark: Identifiable, Codable, Hashable {
    let id: String
    let novelId: String
    let novelTitle: String
    let chapterId: String
    let chapterTitle: String
    let chapterURL: String
    let createdAt: Date
}
