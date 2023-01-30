//
//  iOS14TerminationNews.swift
//  KanaKanjier
//
//  Created by β α on 2022/11/08.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import SwiftUI

struct iOS14TerminationNewsView: View {
    internal init(_ readThisMessage: Binding<Bool>) {
        self._readThisMessage = readThisMessage
    }
    @Binding private var readThisMessage: Bool

    var body: some View {
        TipsContentView("iOS14のサポートを終了します") {
            TipsContentParagraph {
                Text("バージョン1.10(公開時期未定)以降のazooKeyではiOS14のサポートを終了する予定です。")
            }
            TipsContentParagraph {
                Text("iOS15以降では引き続き最新バージョンのazooKeyをご利用いただけます。")
            }
            TipsContentParagraph {
                Text("iOS14に対応する端末は全てiOS15にも対応しています。")
                Text("ぜひiOSをアップデートしてazooKeyをご利用ください。")
            }
        }
        .onAppear {
            self.readThisMessage = true
        }
    }
}
