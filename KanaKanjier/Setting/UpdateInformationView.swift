//
//  UpdateInfomation.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
struct UpdateInfomationView: View {
    var body: some View {
        Form{
            Section{
                VStack(alignment: .leading){
                    Text("ver 1.1")
                        .font(.title2)
                    Text("""
                    ・一部設定項目に説明の表示を追加
                    ・ローマ字キーボードでカーソル移動ビューの高さが変換候補のビューの高さと異なっている問題を修正
                    ・ローマ字キーボードで矢印入力に対応
                    ・unicode変換の接頭辞について、新たにu+, U, U+に対応
                    ・数字の装飾文字変換に対応
                    ・その他デザイン上の軽微な修正
                    """)
                }
            }
            Section{
                VStack(alignment: .leading){
                    Text("ver 1.0")
                        .font(.title2)
                    Text("azooKeyを公開")
                }
            }
        }.navigationBarTitle(Text("更新履歴"), displayMode: .inline)
    }
}
