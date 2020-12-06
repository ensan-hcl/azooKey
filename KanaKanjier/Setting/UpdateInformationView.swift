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
                    HStack{
                        Text("ver 1.2")
                            .font(.headline)
                        Spacer()
                        Text("2020年12月0x日配信")
                            .font(.subheadline)
                    }
                    Text("""
                    ・azooKeyユーザ辞書機能を追加しました。設定からご利用いただけます。
                    ・キーの文字サイズを変更する機能を追加しました。設定からご利用いただけます。
                    ・記号の変換を改善しました。
                    ・その他軽微な操作性の改善を行いました
                    """)
                }
            }

            Section{
                VStack(alignment: .leading){
                    HStack{
                    Text("ver 1.1")
                        .font(.headline)
                    Spacer()
                    Text("2020年12月06日配信")
                        .font(.subheadline)
                    }

                    Text("""
                    ・機能を改善しました。
                    - ローマ字入力中の矢印入力に対応
                    - unicode変換の接頭辞を拡大
                    - 数字の装飾文字変換に対応
                    ・次の問題を修正しました。
                    - 一部候補が正しく学習されない問題
                    - ローマ字入力中の変換の不具合
                    ・その他軽微なデザインの修正を行いました。
                    """)
                }
            }
            Section{
                VStack(alignment: .leading){
                    HStack{
                        Text("ver 1.0")
                            .font(.headline)
                        Spacer()
                        Text("2020年12月04日配信")
                            .font(.subheadline)
                    }

                    Text("azooKeyを公開")
                }
            }
        }.navigationBarTitle(Text("更新履歴"), displayMode: .inline)
    }
}
