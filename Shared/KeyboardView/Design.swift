//
//  Design.swift
//  Keyboard
//
//  Created by ensan on 2020/12/25.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

/// タブに依存するデザイン上の数値を計算する構造体
struct TabDependentDesign {
    let horizontalKeyCount: CGFloat
    let verticalKeyCount: CGFloat
    let layout: KeyboardLayout
    let orientation: KeyboardOrientation

    private var interfaceWidth: CGFloat {
        VariableStates.shared.interfaceSize.width
    }
    private var interfaceHeight: CGFloat {
        VariableStates.shared.interfaceSize.height
    }

    init(width: Int, height: Int, layout: KeyboardLayout, orientation: KeyboardOrientation) {
        self.horizontalKeyCount = CGFloat(width)
        self.verticalKeyCount = CGFloat(height)
        self.layout = layout
        self.orientation = orientation
    }

    init(width: CGFloat, height: CGFloat, layout: KeyboardLayout, orientation: KeyboardOrientation) {
        self.horizontalKeyCount = width
        self.verticalKeyCount = height
        self.layout = layout
        self.orientation = orientation
    }

    /// screenWidthとhorizontalKeyCountに依存
    var keyViewWidth: CGFloat {
        let coefficient: CGFloat
        switch (layout, orientation) {
        case (_, .vertical):
            coefficient = 5 / (5.1 + horizontalKeyCount / 10)
        case (_, .horizontal):
            coefficient = 10 / (10.2 + horizontalKeyCount * 0.28)
        }
        return interfaceWidth / horizontalKeyCount * coefficient
    }

    /// This property calculate suitable height for normal keyView.
    var keyViewHeight: CGFloat {
        let keyHeight = (keysHeight - (verticalKeyCount - 1) * verticalSpacing) / verticalKeyCount
        return keyHeight
    }

    var keysWidth: CGFloat {
        keyViewWidth * horizontalKeyCount + horizontalSpacing * (horizontalKeyCount - 1)
    }

    // resultViewの幅を全体から引いたもの。キーを配置して良い部分の高さ。
    var keysHeight: CGFloat {
        interfaceHeight - (Design.keyboardBarHeight() + 12)
    }

    /// This property is equivarent to `CGSize(width: keyViewWidth, height: keyViewHeight)`. if you want to use only either of two, call `keyViewWidth` or `keyViewHeight` directly.
    var keyViewSize: CGSize {
        CGSize(width: keyViewWidth, height: keyViewHeight)
    }

    var verticalSpacing: CGFloat {
        switch (layout, orientation) {
        case (.flick, .vertical):
            return interfaceWidth * 3 / 140
        case (.flick, .horizontal):
            return interfaceWidth / 107
        case (.qwerty, .vertical):
            return interfaceWidth / 36.6
        case (.qwerty, .horizontal):
            return interfaceWidth / 65
        }
    }

    /// screenWidthとhorizontalKeyCountとkeyViewWidthに依存
    var horizontalSpacing: CGFloat {
        if horizontalKeyCount <= 1 {
            return 0
        }
        let coefficient: CGFloat
        switch orientation {
        case .vertical:
            coefficient = (5 + horizontalKeyCount) / (7.5 + horizontalKeyCount)
        case .horizontal:
            coefficient = (8 + horizontalKeyCount) / (10 + horizontalKeyCount * 1.3)
        }
        return (interfaceWidth - keyViewWidth * horizontalKeyCount) / (horizontalKeyCount - 1) * coefficient
    }

    func keyViewWidth(widthCount: Int) -> CGFloat {
        keyViewWidth * CGFloat(widthCount) + horizontalSpacing * CGFloat(widthCount - 1)
    }

    func keyViewHeight(heightCount: Int) -> CGFloat {
        keyViewHeight * CGFloat(heightCount) + verticalSpacing * CGFloat(heightCount - 1)
    }

    var qwertySpaceKeyWidth: CGFloat {
        keyViewWidth * 5
    }

    var qwertyEnterKeyWidth: CGFloat {
        keyViewWidth * 3
    }

    func qwertyScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keyViewWidth * CGFloat(normal) + horizontalSpacing * CGFloat(normal - 1)
        let spacing = horizontalSpacing * CGFloat(count - 1)
        return (width - spacing) / CGFloat(count)
    }

    func qwertyFunctionalKeyWidth(normal: Int, functional: Int, enter: Int = 0, space: Int = 0) -> CGFloat {
        let maxWidth = keyViewWidth * horizontalKeyCount + horizontalSpacing * (horizontalKeyCount - 1)
        let spacing = horizontalSpacing * CGFloat(normal + functional + space + enter - 1)
        let normalKeyWidth = keyViewWidth * CGFloat(normal)
        let spaceKeyWidth = qwertySpaceKeyWidth * CGFloat(space)
        let enterKeyWidth = qwertyEnterKeyWidth * CGFloat(enter)
        return (maxWidth - (spacing + normalKeyWidth + spaceKeyWidth + enterKeyWidth)) / CGFloat(functional)
    }
}

/// タブに依存せず、キーボード全体で共通するデザイン上の数値を切り出した構造体。
enum Design {
    static let colors = Colors.default
    static let fonts = Fonts.default
    static let language = Language.default

    private static var orientation: KeyboardOrientation {
        VariableStates.shared.keyboardOrientation
    }
    private static var layout: KeyboardLayout {
        VariableStates.shared.keyboardLayout
    }

    /// レイアウトのモード
    enum LayoutMode {
        case phoneVertical
        case phoneHorizontal
        case padVertical
        case padHorizontal
    }

    /// レイアウトモードを決定する
    /// 特に、iPadでフローティングキーボードを利用する場合は`phoneVertical`になる。
    private static var layoutMode: LayoutMode {
        // TODO: この実装は検証される必要がある
        let usePadMode = UIDevice.current.userInterfaceIdiom == .pad
        // floating keyboardの場合
        if usePadMode, SemiStaticStates.shared.screenWidth < 400 {
            return .phoneVertical
        }
        switch (orientation, usePadMode) {
        case (.vertical, false):
            return .phoneVertical
        case (.vertical, true):
            return .padVertical
        case (.horizontal, false):
            return .phoneHorizontal
        case (.horizontal, true):
            return .padHorizontal
        }
    }

    /// This property calculate suitable width for normal keyView.
    static var keyboardScreenHeight: CGFloat {
        keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth, upsideComponent: VariableStates.shared.upsideComponent) + 2
    }

    /// screenWidthに依存して決定する
    /// 12はresultViewのpadding
    static func keyboardHeight(screenWidth: CGFloat = VariableStates.shared.interfaceSize.width, upsideComponent: UpsideComponent? = nil) -> CGFloat {
        let scale: CGFloat
        if let upsideComponent {
            switch orientation {
            case .vertical:
                scale = min(2.2, SemiStaticStates.shared.keyboardHeightScale + upsideComponentScale(upsideComponent).vertical)
            case .horizontal:
                scale = min(2.2, SemiStaticStates.shared.keyboardHeightScale + upsideComponentScale(upsideComponent).horizontal)
            }
        } else {
            scale = SemiStaticStates.shared.keyboardHeightScale
        }
        // 安全装置として、widthが本来のscreenWidthを超えないようにする。
        let width = min(screenWidth, SemiStaticStates.shared.screenWidth)
        switch layoutMode {
        case .phoneVertical:
            return 51 / 74 * width * scale + 12
        case .padVertical:
            return 15 / 31 * width * scale + 12
        case .phoneHorizontal:
            return 17 / 56 * width * scale + 12
        case .padHorizontal:
            return 5 / 18 * width * scale + 12
        }
    }

    private static func upsideComponentScale(_ component: UpsideComponent) -> (vertical: CGFloat, horizontal: CGFloat) {
        switch component {
        case .search:
            return (vertical: 0.5, horizontal: 0.5)
        }
    }

    static func upsideComponentHeight(_ component: UpsideComponent) -> CGFloat {
        Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth, upsideComponent: component) - Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth, upsideComponent: nil)
    }
    /// バー部分の高さは`interfaceHeight`に基づいて決定する
    static func keyboardBarHeight(interfaceHeight: CGFloat = VariableStates.shared.interfaceSize.height) -> CGFloat {
        switch layoutMode {
        case .phoneVertical:
            return (interfaceHeight - 12) * 37 / 204
        // return screenWidth / 8
        case .padVertical:
            return (interfaceHeight - 12) * 31 / 180
        // return screenWidth / 12
        case .phoneHorizontal:
            return (interfaceHeight - 12) * 28 / 153
        // return screenWidth / 18
        case .padHorizontal:
            return (interfaceHeight - 12) * 9 / 55
        // return screenWidth / 22
        }
    }

    static func largeTextViewFontSize(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])
        // 閉じるボタンの高さの分
        return (self.keyboardScreenHeight - self.keyboardScreenHeight * 0.15) / size.height * 10
    }

    enum Fonts {
        case `default`

        private var layout: KeyboardLayout {
            VariableStates.shared.keyboardLayout
        }

        func azooKeyIconFont(fixedSize: CGFloat) -> Font {
            Font.custom("AzooKeyIcon-Regular", fixedSize: fixedSize)
        }

        func azooKeyIconFont(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
            Font.custom("AzooKeyIcon-Regular", size: size, relativeTo: style)
        }

        var iconFontSize: CGFloat {
            @KeyboardSetting(.keyViewFontSize) var userDecidedSize
            if userDecidedSize != -1 {
                return UIFontMetrics.default.scaledValue(for: userDecidedSize)
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        func iconImageFont(theme: ThemeData) -> Font {
            Font.system(size: self.iconFontSize, weight: theme.textFont.weight)
        }

        var resultViewFontSize: CGFloat {
            @KeyboardSetting(.resultViewFontSize) var size
            return size == -1 ? 18: size
        }

        func resultViewFont(theme: ThemeData, fontSize: CGFloat? = nil) -> Font {
            // Font.custom("Mplus 1p Bold", size: resultViewFontSize).weight(theme.textFont.weight)
            Font.system(size: fontSize ?? resultViewFontSize).weight(theme.textFont.weight)
        }

        enum LabelFontSizeStrategy {
            case max
            case large
            case medium
            case small
            case xsmall

            var scale: CGFloat {
                switch self {
                case .large, .max:
                    return 1
                case .medium:
                    return 0.8
                case .small:
                    return 0.7
                case .xsmall:
                    return 0.6
                }
            }
        }

        private func getMaximumFontSize(for text: String, width: CGFloat, maxFontSize: Int) -> CGFloat {
            // 段階的フォールバック
            for fontsize in (10...maxFontSize).reversed() {
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width * 0.95 {
                    return size
                }
            }
            return UIFontMetrics.default.scaledValue(for: 9)
        }

        func keyLabelFont(text: String, width: CGFloat, fontSize: LabelFontSizeStrategy, theme: ThemeData) -> Font {
            if case .max = fontSize {
                let size = self.getMaximumFontSize(for: text, width: width, maxFontSize: 50)
                return Font.system(size: size, weight: theme.textFont.weight, design: .default)
            }

            @KeyboardSetting(.keyViewFontSize) var userDecidedSize
            if userDecidedSize != -1 {
                return .system(size: userDecidedSize * fontSize.scale, weight: theme.textFont.weight, design: .default)
            }
            let maxFontSize: Int
            switch Design.layout {
            case .flick:
                maxFontSize = Int(21 * fontSize.scale)
            case .qwerty:
                maxFontSize = Int(25 * fontSize.scale)
            }
            let size = self.getMaximumFontSize(for: text, width: width, maxFontSize: maxFontSize)
            return Font.system(size: size, weight: theme.textFont.weight, design: .default)
        }
    }

    enum Colors {
        case `default`

        private var layout: KeyboardLayout {
            VariableStates.shared.keyboardLayout
        }

        var backGroundColor: Color {
            Color("BackGroundColor_iOS15")
        }

        var specialEnterKeyColor: Color {
            Color("OpenKeyColor")
        }

        var normalKeyColor: Color {
            switch Design.layout {
            case .flick:
                return Color("NormalKeyColor")
            case .qwerty:
                return Color("RomanKeyColor")
            }
        }

        var specialKeyColor: Color {
            Color("TabKeyColor_iOS15")
        }

        var highlightedKeyColor: Color {
            switch Design.layout {
            case .flick:
                return Color("HighlightedKeyColor")
            case .qwerty:
                return Color("RomanHighlightedKeyColor")
            }
        }

        var suggestKeyColor: Color {
            switch Design.layout {
            case .flick:
                return .systemGray4
            case .qwerty:
                return Color("RomanHighlightedKeyColor")
            }
        }

        func prominentBackgroundColor(_ theme: ThemeData) -> Color {
            ColorTools.hsv(theme.resultBackgroundColor.color) { h, s, v, a in
                Color(hue: h, saturation: s, brightness: min(1, 0.7 * v + 0.3), opacity: min(1, 0.8 * a + 0.2 ))
            } ?? theme.normalKeyFillColor.color
        }
    }

    enum Language {
        case `default`

        func getEnterKeyText(_ state: EnterKeyState) -> String {
            switch state {
            case .complete:
                return "確定"
            case let .return(type):
                switch type {
                case .default:
                    return "改行"
                case .go:
                    return "開く"
                case .google:
                    return "ググる"
                case .join:
                    return "参加"
                case .next:
                    return "次へ"
                case .route:
                    return "経路"
                case .search:
                    return "検索"
                case .send:
                    return "送信"
                case .yahoo:
                    return "Yahoo!"
                case .done:
                    return "完了"
                case .emergencyCall:
                    return "緊急連絡"
                case .continue:
                    return "続行"
                @unknown default:
                    return "改行"
                }
            case .edit:
                return "編集"
            }
        }
    }
}
