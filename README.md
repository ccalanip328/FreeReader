# Free Reader (SwiftUI)

此資料夾是 iOS SwiftUI 專案的原始碼骨架，方便你在 macOS/Xcode 內建立正式專案後直接搬入使用。

## 專案設定
- 專案名稱: Free Reader
- Bundle ID: com.free.reader
- 技術: SwiftUI

## 在 Xcode 內建立專案
1. 開啟 Xcode → New Project → iOS → App
2. Product Name: `Free Reader`
3. Bundle Identifier: `com.free.reader`
4. Interface: `SwiftUI`
5. Language: `Swift`
6. 建立後，把本資料夾內的 `FreeReader` 內容拖進 Xcode 專案（勾選 Copy items if needed）

## 需要加入的套件
在 Xcode 的 Package Dependencies 加入:
- `https://github.com/scinfu/SwiftSoup`

## 專案重點功能
- 首頁搜尋小說（以 `https://tw.hjwzw.com/List/{keyword}` 取得結果）
- 章節列表（以 `https://tw.hjwzw.com/Book/Chapter/{bookId}` 取得）
- 章節閱讀（以 `https://tw.hjwzw.com/Book/Read/{bookId},{readId}` 取得）
- 個人化閱讀設定（背景色、文字色、字級、一次載入章節數）

## 注意事項
- 本專案是「個人自用」導向。若要公開發佈，請務必確認網站授權與使用條款。
- 目前此資料夾不包含 `.xcodeproj`，需在 macOS 上用 Xcode 建立專案。
