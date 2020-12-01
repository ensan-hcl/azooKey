//
//  EmojiKaomojiTipsView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/17.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
struct EmojiKaomojiTipsView: View {
    var body: some View {
        TipsContentView("絵文字や顔文字を変換候補に表示する"){
            TipsContentParagraph{
                Text("絵文字と顔文字は別々にオン・オフを選択可能です。")
                Text("絵文字の一覧を表示したい場合、標準の絵文字キーボードをご利用ください。")
            }

            AdditionalDictManageViewMain()

        }
    }
}
