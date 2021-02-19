//
//  Design.swift
//  Keyboard
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class TabDependentDesign{
    private let horizontalKeyCount: Int
    private let verticalKeyCount: Int
    private let layout: KeyboardLayout
    private let orientation: KeyboardOrientation

    var screenWidth: CGFloat {
        SemiStaticStates.shared.screenWidth
    }

    init(width: Int, height: Int, layout: KeyboardLayout, orientation: KeyboardOrientation){
        self.horizontalKeyCount = width
        self.verticalKeyCount = height
        self.layout = layout
        self.orientation = orientation
    }

    ///This property calculate suitable width for normal keyView.
    var keyViewWidth: CGFloat {
        let coefficient: CGFloat
        switch (layout, orientation){
        case (.flick, .vertical):
            coefficient = 5/5.6
        case (.flick, .horizontal):
            coefficient = 5/9
        case (.qwerty, .vertical):
            coefficient = 10/12.2
        case (.qwerty, .horizontal):
            coefficient = 10/13
        }
        return screenWidth / CGFloat(horizontalKeyCount) * coefficient
    }
    ///This property calculate suitable height for normal keyView.
    var keyViewHeight: CGFloat {
        let keysViewHeight = Design.shared.keyboardHeight - (Design.shared.resultViewHeight + 12)
        let keyHeight = (keysViewHeight - CGFloat(verticalKeyCount-1) * verticalSpacing)/CGFloat(verticalKeyCount)
        return keyHeight
    }

    ///This property is equivarent to `CGSize(width: keyViewWidth, height: keyViewHeight)`. if you want to use only either of two, call `keyViewWidth` or `keyViewHeight` directly.
    var keyViewSize: CGSize {
        CGSize(width: keyViewWidth, height: keyViewHeight)
    }

    var verticalSpacing: CGFloat {
        switch (layout, orientation){
        case (.flick, .vertical):
            //return horizontalSpacing
            return screenWidth*3/140
        case (.flick, .horizontal):
            //return horizontalSpacing / 2の近似値
            return screenWidth/107
        case (.qwerty, .vertical):
            //return keyViewSize.width / 3
            return screenWidth/36.6
        case (.qwerty, .horizontal):
            //return keyViewSize.width / 5
            return screenWidth/65
        }
    }

    var horizontalSpacing: CGFloat {
        let coefficient: CGFloat
        switch (layout, orientation){
        case (.flick, .vertical):
            coefficient = 4/5
        case (.flick, .horizontal):
            coefficient = 1/6
        case (.qwerty, .vertical):
            coefficient = 366/427
        case (.qwerty, .horizontal):
            coefficient = 9/10
        }
        return (screenWidth - keyViewWidth * CGFloat(horizontalKeyCount)) / CGFloat(horizontalKeyCount-1) * coefficient
    }

    var flickEnterKeySize: CGSize {
        CGSize(width: keyViewWidth, height: keyViewHeight * 2 + verticalSpacing)
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
        let maxWidth = keyViewWidth * CGFloat(horizontalKeyCount) + horizontalSpacing * CGFloat(horizontalKeyCount - 1)
        let spacing = horizontalSpacing * CGFloat(normal + functional + space + enter - 1)
        let normalKeyWidth = keyViewWidth * CGFloat(normal)
        let spaceKeyWidth = qwertySpaceKeyWidth * CGFloat(space)
        let enterKeyWidth = qwertyEnterKeyWidth * CGFloat(enter)
        return (maxWidth - (spacing + normalKeyWidth + spaceKeyWidth + enterKeyWidth)) / CGFloat(functional)
    }
}

//MARK:デザイン部門のロジックを全て切り出したオブジェクト。
struct Design{
    private init(){}
    static let shared = Design()
    static let colors = Colors.default
    static let fonts = Fonts.default
    static let language = Language.default

    var orientation: KeyboardOrientation {
        VariableStates.shared.keyboardOrientation
    }
    var layout: KeyboardLayout {
        VariableStates.shared.keyboardLayout
    }
    var screenWidth: CGFloat {
        SemiStaticStates.shared.screenWidth
    }

    /*
    ///KeyViewのサイズを自動で計算して返す。
    var keyViewSize: CGSize {
        let interface = UIDevice.current.userInterfaceIdiom
        switch (layout, orientation){
        case (.flick, .vertical):
            if interface == .pad{
                return CGSize(width: screenWidth/5.6, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/5.6, height: screenWidth/8)
        case (.flick, .horizontal):
            if interface == .pad{
                return CGSize(width: screenWidth/9, height: screenWidth/22)
            }
            return CGSize(width: screenWidth/9, height: screenWidth/18)
        case (.qwerty, .vertical):
            if interface == .pad{
                return CGSize(width: screenWidth/12.2, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/12.2, height: screenWidth/8.3)
        case (.qwerty, .horizontal):
            return CGSize(width: screenWidth/13, height: screenWidth/20)
        }
    }
    */

    /*
    ///This property calculate suitable width for normal keyView.
    var keyViewWidth2: CGFloat {
        switch (layout, orientation){
        case (.flick, .vertical):
            return screenWidth/5.6
        case (.flick, .horizontal):
            return screenWidth/9
        case (.qwerty, .vertical):
            return screenWidth/12.2
        case (.qwerty, .horizontal):
            return screenWidth/13
        }
    }
    */

    ///This property calculate suitable width for normal keyView.
    var keyboardScreenHeight: CGFloat {
        keyboardHeight + 2
    }

    /*
    var keyboardHeight: CGFloat {
        let viewheight = self.keyViewSize.height * CGFloat(self.verticalKeyCount) + self.resultViewHeight
        let spaceheight = self.verticalSpacing * CGFloat(self.verticalKeyCount - 1) + 12.0
        return viewheight + spaceheight
    }
    */

    var keyboardHeight: CGFloat {
        switch (orientation, UIDevice.current.userInterfaceIdiom == .pad){
        case (.vertical, false):
            return 51/74 * screenWidth + 12
        case (.horizontal, false):
            return 17/56 * screenWidth + 12
        case (.vertical, true):
            return 15/31 * screenWidth + 12
        case (.horizontal, true):
            return 5/18 * screenWidth + 12
        }
     }

    var resultViewHeight: CGFloat {
        switch (orientation, UIDevice.current.userInterfaceIdiom == .pad){
        case (.vertical, false):
            return screenWidth / 8
        case (.vertical, true):
            return screenWidth / 12
        case (.horizontal, false):
            return screenWidth / 18
        case (.horizontal, true):
            return screenWidth / 22
        }
    }

    func getMaximumTextSize(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])
        //閉じるボタンの高さの分
        return (self.keyboardHeight - self.keyboardHeight * 0.15) / size.height * 10
    }

    enum Fonts{
        case `default`

        var iconFontSize: CGFloat {
            let userDecidedSize = SettingData.shared.keyViewFontSize
            if userDecidedSize != -1{
                return UIFontMetrics.default.scaledValue(for: CGFloat(userDecidedSize))
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        func iconImageFont(theme: ThemeData) -> Font {
            return Font.system(size: self.iconFontSize, weight: theme.textFont.weight)
        }

        var resultViewFontSize: CGFloat {
            let size = SettingData.shared.resultViewFontSize
            return CGFloat(size == -1 ? 18: size)
        }

        func resultViewFont(theme: ThemeData) -> Font {
            //Font.custom("Mplus 1p Bold", size: resultViewFontSize).weight(theme.textFont.weight)
            Font.system(size: resultViewFontSize).weight(theme.textFont.weight)
        }

        func keyLabelFont(text: String, width: CGFloat, scale: CGFloat, theme: ThemeData) -> Font {
            let userDecidedSize = SettingData.shared.keyViewFontSize
            if userDecidedSize != -1 {
                return .system(size: CGFloat(userDecidedSize) * scale, weight: theme.textFont.weight, design: .default)
            }
            let maxFontSize: Int
            switch Design.shared.layout{
            case .flick:
                maxFontSize = Int(21 * scale)
            case .qwerty:
                maxFontSize = Int(25 * scale)
            }
            //段階的フォールバック
            for fontsize in (10...maxFontSize).reversed(){
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width * 0.95{
                    return Font.system(size: size, weight: theme.textFont.weight, design: .default)
                }
            }
            let size = UIFontMetrics.default.scaledValue(for: 9)
            return Font.system(size: size, weight: theme.textFont.weight, design: .default)
        }
    }

    enum Colors{
        case `default`
        var backGroundColor: Color {
            Color("BackGroundColor")
        }
        var specialEnterKeyColor: Color {
            Color("OpenKeyColor")
        }
        var normalKeyColor: Color {
            switch Design.shared.layout{
            case .flick:
                return Color("NormalKeyColor")
            case .qwerty:
                return Color("RomanKeyColor")
            }
        }
        var specialKeyColor: Color {
            switch Design.shared.layout{
            case .flick:
                return Color("TabKeyColor")
            case .qwerty:
                return Color("TabKeyColor")
            }
        }
        var highlightedKeyColor: Color {
            switch Design.shared.layout{
            case .flick:
                return Color("HighlightedKeyColor")
            case .qwerty:
                return Color("RomanHighlightedKeyColor")
            }
        }
        var suggestKeyColor: Color {
            switch Design.shared.layout{
            case .flick:
                return Color(UIColor.systemGray4)
            case .qwerty:
                return Color("RomanHighlightedKeyColor")
            }
        }
    }

    enum Language{
        case `default`
        func getEnterKeyText(_ state: EnterKeyState) -> String {
            switch state {
            case .complete:
                return "確定"
            case let .return(type):
                switch type{
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
