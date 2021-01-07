//
//  SelctInputStyle.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct SelctInputStyleTipsView:View {
    var body: some View {
        TipsContentView("入力方法を選ぶ"){
            TipsContentParagraph{
                Text("日本語と英語それぞれで「ローマ字入力」または「フリック入力」を選ぶことが可能です。")
            }
            KeyboardLayoutSettingItemView(Store.shared.keyboardTypeSetting, language: .japanese).padding(.vertical)
            KeyboardLayoutSettingItemView(Store.shared.englishKeyboardTypeSetting, language: .english).padding(.vertical)
            TipsContentParagraph(style: .caption){
                Text("現在は携帯電話式の入力については対応していません。")
            }
        }
    }
}
