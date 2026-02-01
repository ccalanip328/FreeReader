import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: ReaderSettings

    var body: some View {
        Form {
            Section("顏色") {
                ColorPicker(
                    "背景色",
                    selection: Binding(
                        get: { settings.backgroundColor },
                        set: { settings.updateBackgroundColor($0) }
                    ),
                    supportsOpacity: false
                )

                ColorPicker(
                    "文字色",
                    selection: Binding(
                        get: { settings.textColor },
                        set: { settings.updateTextColor($0) }
                    ),
                    supportsOpacity: false
                )
            }

            Section("閱讀") {
                Stepper(
                    "文字大小 \(Int(settings.fontSize))",
                    value: $settings.fontSize,
                    in: 12...30,
                    step: 1
                )

                Stepper(
                    "一次載入章節 \(settings.chaptersPerLoad)",
                    value: $settings.chaptersPerLoad,
                    in: 1...10
                )
            }
        }
        .navigationTitle("設定")
    }
}
