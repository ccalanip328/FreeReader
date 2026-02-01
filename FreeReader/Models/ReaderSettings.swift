import SwiftUI
import UIKit

final class ReaderSettings: ObservableObject {
    private enum Keys {
        static let bgR = "bg_r"
        static let bgG = "bg_g"
        static let bgB = "bg_b"
        static let textR = "text_r"
        static let textG = "text_g"
        static let textB = "text_b"
        static let fontSize = "font_size"
        static let chaptersPerLoad = "chapters_per_load"
    }

    @Published var bgR: Double { didSet { save(bgR, key: Keys.bgR) } }
    @Published var bgG: Double { didSet { save(bgG, key: Keys.bgG) } }
    @Published var bgB: Double { didSet { save(bgB, key: Keys.bgB) } }

    @Published var textR: Double { didSet { save(textR, key: Keys.textR) } }
    @Published var textG: Double { didSet { save(textG, key: Keys.textG) } }
    @Published var textB: Double { didSet { save(textB, key: Keys.textB) } }

    @Published var fontSize: Double { didSet { save(fontSize, key: Keys.fontSize) } }
    @Published var chaptersPerLoad: Int { didSet { save(chaptersPerLoad, key: Keys.chaptersPerLoad) } }

    init() {
        bgR = Self.load(key: Keys.bgR, defaultValue: 0.98)
        bgG = Self.load(key: Keys.bgG, defaultValue: 0.97)
        bgB = Self.load(key: Keys.bgB, defaultValue: 0.95)
        textR = Self.load(key: Keys.textR, defaultValue: 0.12)
        textG = Self.load(key: Keys.textG, defaultValue: 0.12)
        textB = Self.load(key: Keys.textB, defaultValue: 0.12)
        fontSize = Self.load(key: Keys.fontSize, defaultValue: 18)
        chaptersPerLoad = Self.load(key: Keys.chaptersPerLoad, defaultValue: 3)
    }

    var backgroundColor: Color {
        Color(.sRGB, red: bgR, green: bgG, blue: bgB, opacity: 1)
    }

    var textColor: Color {
        Color(.sRGB, red: textR, green: textG, blue: textB, opacity: 1)
    }

    func updateBackgroundColor(_ color: Color) {
        let components = colorComponents(from: color)
        bgR = components.red
        bgG = components.green
        bgB = components.blue
    }

    func updateTextColor(_ color: Color) {
        let components = colorComponents(from: color)
        textR = components.red
        textG = components.green
        textB = components.blue
    }

    private func colorComponents(from color: Color) -> (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (Double(r), Double(g), Double(b))
        }
        return (1, 1, 1)
    }

    private func save<T>(_ value: T, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private static func load<T>(key: String, defaultValue: T) -> T {
        if let value = UserDefaults.standard.object(forKey: key) as? T {
            return value
        }
        return defaultValue
    }
}
