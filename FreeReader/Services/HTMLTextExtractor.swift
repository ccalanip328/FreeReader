import Foundation
import SwiftSoup

enum HTMLTextExtractor {
    static func extractMainText(from html: String, title: String?) throws -> String {
        let document = try SwiftSoup.parse(html)

        if let element = try findPrimaryContentElement(in: document, title: title) {
            return cleanText(from: element)
        }

        let bodyText = try document.body()?.wholeText() ?? ""
        return sanitize(text: bodyText)
    }

    private static func findPrimaryContentElement(in document: Document, title: String?) throws -> Element? {
        let selectors = [
            "#content",
            "#BookText",
            "#BookContent",
            ".content",
            ".book_content",
            ".chapter-content",
            ".txt",
            "article",
            "section",
            "div"
        ]

        var bestElement: Element?
        var bestScore = 0

        for selector in selectors {
            let elements = try document.select(selector)
            for element in elements.array() {
                let text = try element.wholeText()
                let length = text.trimmingCharacters(in: .whitespacesAndNewlines).count
                if length < 200 { continue }

                let linkCount = try element.select("a").count
                let penalty = linkCount * 20
                var score = length - penalty

                if let title, !title.isEmpty, text.contains(title) {
                    score += 200
                }

                if score > bestScore {
                    bestScore = score
                    bestElement = element
                }
            }

            if bestScore > 0, selector != "div" {
                break
            }
        }

        return bestElement
    }

    private static func cleanText(from element: Element) -> String {
        var html = (try? element.html()) ?? ""
        html = html.replacingOccurrences(of: "<br>", with: "\n")
        html = html.replacingOccurrences(of: "<br/>", with: "\n")
        html = html.replacingOccurrences(of: "<br />", with: "\n")
        html = html.replacingOccurrences(of: "</p>", with: "\n")
        html = html.replacingOccurrences(of: "<p>", with: "")

        let fragment = try? SwiftSoup.parseBodyFragment(html)
        let text = (try? fragment?.body()?.wholeText()) ?? ""
        return sanitize(text: text)
    }

    private static func sanitize(text: String) -> String {
        let removePhrases = [
            "請記住本站域名",
            "黃金屋中文",
            "快捷鍵",
            "上一章",
            "下一章",
            "返回書頁",
            "道君目錄",
            "目錄",
            "書架",
            "手機網頁版"
        ]

        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { line in
                !removePhrases.contains { line.contains($0) }
            }

        return lines.joined(separator: "\n\n")
    }
}
