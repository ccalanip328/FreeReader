import Foundation

struct Favorite: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let url: String
}
