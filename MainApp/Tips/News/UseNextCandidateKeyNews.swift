//
//  UseNextCandidateKeyNews.swift
//  azooKey
//
//  Created by miwa on 2023/11/11.
//  Copyright © 2023 DevEn3. All rights reserved.
//

import SwiftUI

struct UseNextCandidateKeyNews: View {
    var body: some View {
        TipsContentView("シフトキーを使う") {
            TipsContentParagraph {
                Text("空白キーに「次候補」ボタンを表示するには、次の設定をオンにしてください")
            }
            BoolSettingView(.useNextCandidateKey)
        }
    }
}
