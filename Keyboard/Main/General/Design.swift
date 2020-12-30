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

    ///do not  consider using screenHeight
    private(set) var screenWidth: CGFloat = .zero

    private var keyboardLayoutType: KeyboardLayoutType {
        Store.shared.keyboardLayoutType
    }

    var keyboardWidth: CGFloat {
        return self.keyViewSize.width * CGFloat(self.horizontalKeyCount) + self.keyViewHorizontalSpacing * CGFloat(self.horizontalKeyCount-1)
    }

    var keyboardHeight: CGFloat {
        let viewheight = self.keyViewSize.height * CGFloat(self.verticalKeyCount) + self.resultViewHeight
        let vSpacing = self.keyViewVerticalSpacing
        switch keyboardLayoutType{
        case .flick:
            //ビューの実装では、フリックでは縦に4列なので3つの縦スペーシング + 上に縦スペーシング1つ分のpadding + 候補ビュー間6pxのpadding
            let spaceheight = vSpacing * CGFloat(self.verticalKeyCount - 1) + vSpacing + 6.0
            return viewheight + spaceheight + 2
        case .roman:
            //4つなので3つの縦スペーシング + 上下6pxのpadding
            let spaceheight = vSpacing * CGFloat(self.verticalKeyCount - 1) + 12.0
            return viewheight + spaceheight + 2
        }
    }

    var verticalKeyCount: Int {
        switch keyboardLayoutType{
        case .flick:
            return 4
        case .roman:
            return 4
        }
    }

    var horizontalKeyCount: Int {
        switch keyboardLayoutType{
        case .flick:
            return 5
        case .roman:
            return 10
        }
    }

    ///KeyViewのサイズを自動で計算して返す。
    var keyViewSize: CGSize {
        switch (keyboardLayoutType, orientation){
        case (.flick, .vertical):
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: screenWidth/5.6, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/5.6, height: screenWidth/8)
        case (.flick, .horizontal):
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: screenWidth/9, height: screenWidth/22)
            }
            return CGSize(width: screenWidth/9, height: screenWidth/18)
        case (.roman, .vertical):
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: screenWidth/12.2, height: screenWidth/12)
            }
            return CGSize(width: screenWidth/12.2, height: screenWidth/9)
        case (.roman, .horizontal):
            return CGSize(width: screenWidth/13, height: screenWidth/20)
        }
    }

    var keyViewVerticalSpacing: CGFloat {
        switch (keyboardLayoutType, orientation){
        case (.flick, .vertical):
            return keyViewHorizontalSpacing
        case (.flick, .horizontal):
            return keyViewHorizontalSpacing/2
        case (.roman, .vertical):
            return keyViewSize.width/3
        case (.roman, .horizontal):
            return keyViewSize.width/5
        }
    }

    var keyViewHorizontalSpacing: CGFloat {
        switch (keyboardLayoutType, orientation){
        case (.flick, .vertical):
            return (screenWidth - keyViewSize.width * 5)/5
        case (.flick, .horizontal):
            return (screenWidth - screenWidth*10/13)/12 - 0.5
        case (.roman, .vertical):
            //9だとself.horizontalKeyCount-1で画面ぴったりになるが、それだとあまりにピシピシなので0.1を加えて調整する。
            return (screenWidth - keyViewSize.width * CGFloat(self.horizontalKeyCount))/(9+0.5)
        case (.roman, .horizontal):
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
        return CGSize(width: size.width, height: size.height*2 + keyViewVerticalSpacing)
    }

    var romanSpaceKeyWidth: CGFloat {
        return keyViewSize.width*5
    }

    var romanEnterKeyWidth: CGFloat {
        return keyViewSize.width*3
    }

    func romanScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keyViewSize.width * CGFloat(normal) + keyViewHorizontalSpacing * CGFloat(normal - 1)
        let spacing = keyViewHorizontalSpacing * CGFloat(count - 1)
        return (width - spacing) / CGFloat(count)
    }

    func romanFunctionalKeyWidth(normal: Int, functional: Int, enter: Int = 0, space: Int = 0) -> CGFloat {
        let maxWidth = keyboardWidth
        let spacing = keyViewHorizontalSpacing * CGFloat(normal + functional + space + enter - 1)
        let normalKeyWidth = keyViewSize.width * CGFloat(normal)
        let spaceKeyWidth = romanSpaceKeyWidth * CGFloat(space)
        let enterKeyWidth = romanEnterKeyWidth * CGFloat(enter)
        return (maxWidth - (spacing + normalKeyWidth + spaceKeyWidth + enterKeyWidth)) / CGFloat(functional)
    }

    func getMaximumTextSize(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])
        return self.keyboardHeight/size.height * 10
    }

    func isOverScreenWidth(_ value: CGFloat) -> Bool {
        return screenWidth < value
    }

    func registerScreenWidth(width: CGFloat){
        self.screenWidth = width
    }

    func registerScreenSize(size: CGSize){
        if self.screenWidth == size.width{
            return
        }
        self.registerScreenWidth(width: size.width)
        let orientation: KeyboardOrientation = size.width<size.height ? .vertical : .horizontal
        Store.shared.setOrientation(orientation)
    }

    let colors = Colors.default
    let fonts = Fonts.default

    enum Fonts{
        case `default`

        var iconFontSize: CGFloat {
            let userDecidedSize = Store.shared.userSetting.keyViewFontSize
            if userDecidedSize != -1{
                return UIFontMetrics.default.scaledValue(for: CGFloat(userDecidedSize))
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        var iconImageFont: Font {
            let size = self.iconFontSize
            return Font.system(size: size, weight: .regular)
        }

        var resultViewFontSize: CGFloat {
            let size = Store.shared.userSetting.resultViewFontSize
            return CGFloat(size == -1 ? 18: size)
        }

        var resultViewFont: Font {
            .system(size: resultViewFontSize)
        }

        func keyLabelFont(text: String, width: CGFloat, scale: CGFloat) -> Font {
            let userDecidedSize = Store.shared.userSetting.keyViewFontSize
            if userDecidedSize != -1 {
                return .system(size: CGFloat(userDecidedSize) * scale, weight: .regular, design: .default)
            }
            let maxFontSize: Int
            switch Store.shared.keyboardLayoutType{
            case .flick:
                maxFontSize = Int(21*scale)
            case .roman:
                maxFontSize = Int(25*scale)
            }
            //段階的フォールバック
            for fontsize in (10...maxFontSize).reversed(){
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width*0.95{
                    return Font.system(size: size, weight: .regular, design: .default)
                }
            }
            let size = UIFontMetrics.default.scaledValue(for: 9)
            return Font.system(size: size, weight: .regular, design: .default)
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
            switch Store.shared.keyboardLayoutType{
            case .flick:
                return Color("NormalKeyColor")
            case .roman:
                return Color("RomanKeyColor")
            }
        }
        var specialKeyColor: Color {
            switch Store.shared.keyboardLayoutType{
            case .flick:
                return Color("TabKeyColor")
            case .roman:
                return Color("TabKeyColor")
            }
        }
        var highlightedKeyColor: Color {
            switch Store.shared.keyboardLayoutType{
            case .flick:
                return Color("HighlightedKeyColor")
            case .roman:
                return Color("RomanHighlightedKeyColor")
            }
        }
    }

}
