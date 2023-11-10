//
//  UseShiftKeyNews.swift
//  azooKey
//
//  Created by miwa on 2023/11/10.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import SwiftUI

struct UseShiftKeyNews: View {
    var body: some View {
        TipsContentView("シフトキーを使う") {
            TipsContentParagraph {
                Text("Qwerty英語キーボードでシフトキーを使いたい場合、次の設定をオンにしてください")
            }
            BoolSettingView(.useShiftKey)
        }
    }
}
