import SwiftUI

struct BookmarksView: View {
    let novel: Novel
    let chapters: [Chapter]
    @EnvironmentObject private var library: LibraryStore

    var body: some View {
        List {
            if bookmarks.isEmpty {
                Text("尚無書籤")
                    .foregroundColor(.secondary)
            } else {
                ForEach(bookmarks) { bookmark in
                    if let index = chapters.firstIndex(where: { $0.id == bookmark.chapterId }) {
                        NavigationLink(bookmark.chapterTitle) {
                            ReaderView(
                                novel: novel,
                                chapters: Array(chapters[index...])
                            )
                        }
                    } else {
                        Text(bookmark.chapterTitle)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("書籤")
        .toolbar {
            EditButton()
        }
    }

    private var bookmarks: [Bookmark] {
        library.bookmarks(for: novel.id)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let bookmark = bookmarks[index]
            library.removeBookmark(bookmark)
        }
    }
}
