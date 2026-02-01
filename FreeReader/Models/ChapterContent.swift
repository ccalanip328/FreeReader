import Foundation

struct ChapterContent: Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let sourceURL: URL
}
