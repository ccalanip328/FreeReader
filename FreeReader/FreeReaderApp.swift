import SwiftUI

@main
struct FreeReaderApp: App {
    @StateObject private var settings = ReaderSettings()
    @StateObject private var library = LibraryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(library)
        }
    }
}
