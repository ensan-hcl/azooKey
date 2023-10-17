//
//  iOS15TerminationNews.swift
//  MainApp
//
//  Created by ensan on 2022/11/08.
//  Copyright © 2022 ensan. All rights reserved.
//

import SwiftUI

// swiftlint:disable:next type_name
struct iOS15TerminationNewsView: View {
    internal init(_ readThisMessage: Binding<Bool>) {
        self._readThisMessage = readThisMessage
    }
    @Binding private var readThisMessage: Bool

    var body: some View {
        TipsContentView("iOS15のサポートを終了します") {
            TipsContentParagraph {
                Text("バージョン2.3(公開時期未定)以降のazooKeyではiOS15のサポートを終了する予定です。")
            }
            TipsContentParagraph {
                Text("iOS16以降では引き続き最新バージョンのazooKeyをご利用いただけます。")
            }
            TipsContentParagraph {
                Text("ぜひiOSをアップデートしてazooKeyをご利用ください。")
            }
        }
        .onAppear {
            self.readThisMessage = true
        }
    }
}
