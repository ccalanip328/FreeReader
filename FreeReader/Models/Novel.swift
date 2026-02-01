import Foundation

struct Novel: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL
    let author: String?
    let summary: String?
}
