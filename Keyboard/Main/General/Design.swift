//
//  Design.swift
//  Keyboard
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
//MARK:デザイン部門のロジックを全て切り出したオブジェクト。
final class Design{
    private init(){}
    static let shared = Design()

    var orientation: KeyboardOrientation = .vertical
    var layout: KeyboardLayout = .flick

    var themeManager = ThemeManager()

    ///do not  consider using screenHeight
    private(set) var screenWidth: CGFloat = .zero

    ///KeyViewのサイズを自動で計算して返す。
    var keyViewSize: CGSize {
        DesignLogic.keyViewSize(keyboardLayout: layout, orientation: orientation, screenWidth: screenWidth)
    }

    var keyboardWidth: CGFloat {
        return self.keyViewSize.width * CGFloat(self.horizontalKeyCount) + self.horizontalSpacing * CGFloat(self.horizontalKeyCount-1)
    }

    var keyboardHeight: CGFloat {
        let viewheight = self.keyViewSize.height * CGFloat(self.verticalKeyCount) + self.resultViewHeight
        let vSpacing = self.verticalSpacing
        switch layout{
        case .flick:
            //ビューの実装では、フリックでは縦に4列なので3つの縦スペーシング + 上下6pxのpadding
            let spaceheight = vSpacing * CGFloat(self.verticalKeyCount - 1) + 12.0
            return viewheight + spaceheight
        case .qwerty:
            //4つなので3つの縦スペーシング + 上下6pxのpadding
            let spaceheight = vSpacing * CGFloat(self.verticalKeyCount - 1) + 12.0
            return viewheight + spaceheight
        }
    }

    var verticalKeyCount: Int {
        switch layout{
        case .flick:
            return 4
        case .qwerty:
            return 4
        }
    }

    var horizontalKeyCount: Int {
        switch layout{
        case .flick:
            return 5
        case .qwerty:
            return 10
        }
    }

    var verticalSpacing: CGFloat {
        switch (layout, orientation){
        case (.flick, .vertical):
            return horizontalSpacing
        case (.flick, .horizontal):
            return horizontalSpacing/2
        case (.qwerty, .vertical):
            return keyViewSize.width/3
        case (.qwerty, .horizontal):
            return keyViewSize.width/5
        }
    }

    var horizontalSpacing: CGFloat {
        switch (layout, orientation){
        case (.flick, .vertical):
            return (screenWidth - keyViewSize.width * 5)/5
        case (.flick, .horizontal):
            return (screenWidth - screenWidth*10/13)/12 - 0.5
        case (.qwerty, .vertical):
            //9だとself.horizontalKeyCount-1で画面ぴったりになるが、それだとあまりにピシピシなので0.1を加えて調整する。
            return (screenWidth - keyViewSize.width * CGFloat(self.horizontalKeyCount))/(9+0.5)
        case (.qwerty, .horizontal):
            return (screenWidth - keyViewSize.width * CGFloat(self.horizontalKeyCount))/10
        }
    }

    var resultViewHeight: CGFloat {
        switch orientation{
        case .vertical:
            if UIDevice.current.userInterfaceIdiom == .pad{
                return screenWidth/12
            }
            return screenWidth/8
        case .horizontal:
            if UIDevice.current.userInterfaceIdiom == .pad{
                return screenWidth/22
            }
            return screenWidth/18
        }
    }

    var flickEnterKeySize: CGSize {
        let size = keyViewSize
        return CGSize(width: size.width, height: size.height*2 + verticalSpacing)
    }

    var qwertySpaceKeyWidth: CGFloat {
        return keyViewSize.width*5
    }

    var qwertyEnterKeyWidth: CGFloat {
        return keyViewSize.width*3
    }

    func qwertyScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keyViewSize.width * CGFloat(normal) + horizontalSpacing * CGFloat(normal - 1)
        let spacing = horizontalSpacing * CGFloat(count - 1)
        return (width - spacing) / CGFloat(count)
    }

    func qwertyFunctionalKeyWidth(normal: Int, functional: Int, enter: Int = 0, space: Int = 0) -> CGFloat {
        let maxWidth = keyboardWidth
        let spacing = horizontalSpacing * CGFloat(normal + functional + space + enter - 1)
        let normalKeyWidth = keyViewSize.width * CGFloat(normal)
        let spaceKeyWidth = qwertySpaceKeyWidth * CGFloat(space)
        let enterKeyWidth = qwertyEnterKeyWidth * CGFloat(enter)
        return (maxWidth - (spacing + normalKeyWidth + spaceKeyWidth + enterKeyWidth)) / CGFloat(functional)
    }

    func getMaximumTextSize(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])
        return (self.keyboardHeight - self.keyViewSize.height*1.2)/size.height * 10
    }

    func isOverScreenWidth(_ value: CGFloat) -> Bool {
        return screenWidth < value
    }

    func setScreenSize(size: CGSize){
        if self.screenWidth == size.width{
            return
        }
        self.screenWidth = size.width
        let orientation: KeyboardOrientation = size.width<size.height ? .vertical : .horizontal
        Store.shared.setOrientation(orientation)
    }

    let colors = Colors.default
    let fonts = Fonts.default
    let language = Language.default

    enum Fonts{
        case `default`

        var themeFontWeight: Font.Weight {
            Design.shared.themeManager.weight
        }

        var iconFontSize: CGFloat {
            let userDecidedSize = SettingData.shared.keyViewFontSize
            if userDecidedSize != -1{
                return UIFontMetrics.default.scaledValue(for: CGFloat(userDecidedSize))
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        var iconImageFont: Font {
            let size = self.iconFontSize
            return Font.system(size: size, weight: themeFontWeight)
        }

        var resultViewFontSize: CGFloat {
            let size = SettingData.shared.resultViewFontSize
            return CGFloat(size == -1 ? 18: size)
        }

        var resultViewFont: Font {
            return Font.system(size: resultViewFontSize).weight(themeFontWeight)
        }

        func keyLabelFont(text: String, width: CGFloat, scale: CGFloat) -> Font {
            let userDecidedSize = SettingData.shared.keyViewFontSize
            if userDecidedSize != -1 {
                return .system(size: CGFloat(userDecidedSize) * scale, weight: themeFontWeight, design: .default)
            }
            let maxFontSize: Int
            switch Design.shared.layout{
            case .flick:
                maxFontSize = Int(21*scale)
            case .qwerty:
                maxFontSize = Int(25*scale)
            }
            //段階的フォールバック
            for fontsize in (10...maxFontSize).reversed(){
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width*0.95{
                    return Font.system(size: size, weight: themeFontWeight, design: .default)
                }
            }
            let size = UIFontMetrics.default.scaledValue(for: 9)
            return Font.system(size: size, weight: themeFontWeight, design: .default)
        }
    }

    enum Colors{
        case `default`
        var backGroundColor: Color {
            return Color("BackGroundColor")
        }
        var specialEnterKeyColor: Color {
            return Color("OpenKeyColor")
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

struct ThemeManager{
    let theme: ThemeData

    var weight: Font.Weight {
        switch theme.textFont {
        case .normal:
            return .regular
        case .bold:
            return .bold
        }
    }

    ///少し濃い透明度
    var weakOpacity: Double {
        sqrt(self.theme.keyBackgroundColorOpacity)
    }

    ///指定された透明度
    var mainOpacity: Double {
        self.theme.keyBackgroundColorOpacity
    }

    fileprivate init(){
        self.theme = Self.getSelectedTheme()
    }

    static func getSelectedTheme() -> ThemeData {
        return ThemeData.default
    }
}
