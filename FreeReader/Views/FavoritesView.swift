import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var library: LibraryStore

    var body: some View {
        List {
            if library.favorites.isEmpty {
                Text("尚無收藏")
                    .foregroundColor(.secondary)
            } else {
                ForEach(library.favorites) { favorite in
                    NavigationLink(favorite.title) {
                        ChapterListView(
                            novel: Novel(
                                id: favorite.id,
                                title: favorite.title,
                                url: URL(string: favorite.url)!,
                                author: nil,
                                summary: nil
                            )
                        )
                    }
                }
            }
        }
        .navigationTitle("收藏")
    }
}
