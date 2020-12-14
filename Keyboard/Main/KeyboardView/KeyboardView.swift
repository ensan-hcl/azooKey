//
//  KeyboardView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

//キーボードの状態管理
enum TabState: Equatable{
    case hira
    case abc
    case number
    case other(String)

    static func ==(lhs: TabState, rhs: TabState) -> Bool {
        switch (lhs, rhs) {
        case (.hira, .hira), (.abc, .abc), (.number, .number): return true
        case let (.other(ls), .other(rs)): return ls == rs
        default:
            return false
        }
    }
}

enum KeyboardLanguage{
    case english
    case japanese
}

enum KeyboardOrientation{
    case vertical       //width<height
    case horizontal     //height<width
}

//keyboard type, orientationに関わらず保持すべきデータ。
final class KeyboardModelVariableSection: ObservableObject{
    @Published var keyboardOrientation: KeyboardOrientation = .vertical
    @Published var isTextMagnifying = false
    @Published var magnifyingText = ""
    @Published var refreshing = true
    func refreshView(){
        refreshing.toggle()
    }
}

struct KeyboardView: View {
    //二つ以上になったらまとめてvariableSectioinにすること！
    @ObservedObject private var modelVariableSection = Store.shared.keyboardModelVariableSection
    var body: some View {
        ZStack{[unowned modelVariableSection] in
            Store.shared.design.colors.backGroundColor
                .frame(maxWidth: .infinity)

            if modelVariableSection.refreshing{
                switch modelVariableSection.keyboardOrientation{
                case .vertical:
                    switch Store.shared.keyboardType {
                    case .flick:
                        VerticalFlickKeyboardView(Store.shared.keyboardModel as! VerticalFlickKeyboardModel)
                    case .roman:
                        VerticalRomanKeyboardView(Store.shared.keyboardModel as! VerticalRomanKeyboardModel)
                    }
                case .horizontal:
                    switch Store.shared.keyboardType {
                    case .flick:
                        HorizontalKeyboardView(Store.shared.keyboardModel as! HorizontalFlickKeyboardModel)
                    case .roman:
                        HorizontalRomanKeyboardView(Store.shared.keyboardModel as! HorizontalRomanKeyboardModel)
                    }
                }
            }else{
                switch modelVariableSection.keyboardOrientation{
                case .vertical:
                    switch Store.shared.keyboardType {
                    case .flick:
                        VerticalFlickKeyboardView(Store.shared.keyboardModel as! VerticalFlickKeyboardModel)
                    case .roman:
                        VerticalRomanKeyboardView(Store.shared.keyboardModel as! VerticalRomanKeyboardModel)
                    }
                case .horizontal:
                    switch Store.shared.keyboardType {
                    case .flick:
                        HorizontalKeyboardView(Store.shared.keyboardModel as! HorizontalFlickKeyboardModel)
                    case .roman:
                        HorizontalRomanKeyboardView(Store.shared.keyboardModel as! HorizontalRomanKeyboardModel)
                    }
                }

            }
            if modelVariableSection.isTextMagnifying{
                LargeTextView(modelVariableSection.magnifyingText)
            }
        }

    }
    
}
