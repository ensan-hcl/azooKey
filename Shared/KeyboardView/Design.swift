//
//  Design.swift
//  Keyboard
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

/// タブに依存するデザイン上の数値を計算するクラス
final class TabDependentDesign {
    private let horizontalKeyCount: CGFloat
    private let verticalKeyCount: CGFloat
    private let layout: KeyboardLayout
    private let orientation: KeyboardOrientation

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
            coefficient = 5/(5.1 + horizontalKeyCount/10)
        case (_, .horizontal):
            coefficient = 10/(10.2 + horizontalKeyCount * 0.28)
        }
        return interfaceWidth / horizontalKeyCount * coefficient
    }

    /// This property calculate suitable height for normal keyView.
    var keyViewHeight: CGFloat {
        let keyHeight = (keysHeight - (verticalKeyCount-1) * verticalSpacing)/verticalKeyCount
        return keyHeight
    }

    var keysWidth: CGFloat {
        keyViewWidth * horizontalKeyCount + horizontalSpacing * (horizontalKeyCount-1)
    }

    // resultViewの幅を全体から引いたもの。キーを配置して良い部分の高さ。
    var keysHeight: CGFloat {
        interfaceHeight - (Design.resultViewHeight() + 12)
    }

    /// This property is equivarent to `CGSize(width: keyViewWidth, height: keyViewHeight)`. if you want to use only either of two, call `keyViewWidth` or `keyViewHeight` directly.
    var keyViewSize: CGSize {
        CGSize(width: keyViewWidth, height: keyViewHeight)
    }

    var verticalSpacing: CGFloat {
        switch (layout, orientation) {
        case (.flick, .vertical):
            return interfaceWidth*3/140
        case (.flick, .horizontal):
            return interfaceWidth/107
        case (.qwerty, .vertical):
            return interfaceWidth/36.6
        case (.qwerty, .horizontal):
            return interfaceWidth/65
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
            coefficient = (5+horizontalKeyCount)/(7.5+horizontalKeyCount)
        case .horizontal:
            coefficient = (8+horizontalKeyCount)/(10+horizontalKeyCount)
        }
        return (interfaceWidth - keyViewWidth * horizontalKeyCount) / (horizontalKeyCount-1) * coefficient
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
    typealias shared = Self
    static let colors = Colors.default
    static let fonts = Fonts.default
    static let language = Language.default

    private static var orientation: KeyboardOrientation {
        VariableStates.shared.keyboardOrientation
    }
    private static var layout: KeyboardLayout {
        VariableStates.shared.keyboardLayout
    }

    /// This property calculate suitable width for normal keyView.
    /// キーボードの高さはスクリーンの幅から決定するため、キーボードスクリーンの高さはこのように書いて良い。
    static var keyboardScreenHeight: CGFloat {
        keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth) + 2
    }

    /// screenWidthに依存して決定する
    /// 12はresultViewのpadding
    static func keyboardHeight(screenWidth: CGFloat = VariableStates.shared.interfaceSize.width) -> CGFloat {
        switch (orientation, UIDevice.current.userInterfaceIdiom == .pad) {
        case (.vertical, false):
            return 51/74 * screenWidth + 12
        case (.vertical, true):
            return 15/31 * screenWidth + 12
        case (.horizontal, false):
            return 17/56 * screenWidth + 12
        case (.horizontal, true):
            return 5/18 * screenWidth + 12
        }
    }

    /// keyboardHeightに依存して決定する
    static func resultViewHeight(keyboardHeight: CGFloat = VariableStates.shared.interfaceSize.height) -> CGFloat {
        // let keyboardHeight = self.keyboardHeight(screenWidth: screenWidth)
        switch (orientation, UIDevice.current.userInterfaceIdiom == .pad) {
        case (.vertical, false):
            return (keyboardHeight - 12) * 37 / 204
        // return screenWidth / 8
        case (.vertical, true):
            return (keyboardHeight - 12) * 31 / 180
        // return screenWidth / 12
        case (.horizontal, false):
            return (keyboardHeight - 12) * 28 / 153
        // return screenWidth / 18
        case (.horizontal, true):
            return (keyboardHeight - 12) * 9 / 55
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
            return Font.custom("AzooKeyIcon-Regular", fixedSize: fixedSize)
        }

        func azooKeyIconFont(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
            return Font.custom("AzooKeyIcon-Regular", size: size, relativeTo: style)
        }

        var iconFontSize: CGFloat {
            @KeyboardSetting(.keyViewFontSize) var userDecidedSize
            if userDecidedSize != -1 {
                return UIFontMetrics.default.scaledValue(for: userDecidedSize)
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        func iconImageFont(theme: ThemeData) -> Font {
            return Font.system(size: self.iconFontSize, weight: theme.textFont.weight)
        }

        var resultViewFontSize: CGFloat {
            @KeyboardSetting(.resultViewFontSize) var size
            return size == -1 ? 18: size
        }

        func resultViewFont(theme: ThemeData) -> Font {
            // Font.custom("Mplus 1p Bold", size: resultViewFontSize).weight(theme.textFont.weight)
            Font.system(size: resultViewFontSize).weight(theme.textFont.weight)
        }

        func keyLabelFont(text: String, width: CGFloat, scale: CGFloat, theme: ThemeData) -> Font {
            @KeyboardSetting(.keyViewFontSize) var userDecidedSize
            if userDecidedSize != -1 {
                return .system(size: userDecidedSize * scale, weight: theme.textFont.weight, design: .default)
            }
            let maxFontSize: Int
            switch Design.layout {
            case .flick:
                maxFontSize = Int(21 * scale)
            case .qwerty:
                maxFontSize = Int(25 * scale)
            }
            // 段階的フォールバック
            for fontsize in (10...maxFontSize).reversed() {
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width * 0.95 {
                    return Font.system(size: size, weight: theme.textFont.weight, design: .default)
                }
            }
            let size = UIFontMetrics.default.scaledValue(for: 9)
            return Font.system(size: size, weight: theme.textFont.weight, design: .default)
        }
    }

    enum Colors {
        case `default`

        private var layout: KeyboardLayout {
            VariableStates.shared.keyboardLayout
        }

        var backGroundColor: Color {
            if #available(iOS 15, *) {
                return Color("BackGroundColor_iOS15")
            } else {
                return Color("BackGroundColor")
            }
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
            return Color("TabKeyColor")
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
