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
                    HeadlineView("1.2", releaseDate: "2020年12月xx日")
                    ParagraphView("azooKeyユーザ辞書機能を追加しました。設定からご利用いただけます。", points: [])
                    ParagraphView("キーの文字サイズを変更する機能を追加しました。設定からご利用いただけます。", points: [])
                    ParagraphView("記号の変換を改善しました。", points: [])
                    ParagraphView("その他軽微な操作性の改善を行いました。", points: [])
                }
            }

            Section{
                VStack(alignment: .leading){
                    HeadlineView("1.1", releaseDate: "2020年12月06日")
                    ParagraphView("機能を改善しました。", points: [
                        "ローマ字入力中の矢印入力に対応",
                        "unicode変換の接頭辞を拡大",
                        "数字の装飾文字変換に対応"
                    ])
                    ParagraphView("次の問題を修正しました。", points: [
                        "一部候補が正しく学習されない問題",
                        "ローマ字入力中の変換の不具合"
                    ])
                    ParagraphView("その他軽微なデザインの修正を行いました。", points: [])
                }
            }
            Section{
                VStack(alignment: .leading){
                    HeadlineView("1.0", releaseDate: "2020年12月04日")
                    ParagraphView("azooKeyを公開しました。", points: [])
                }
            }
        }.navigationBarTitle(Text("更新履歴"), displayMode: .inline)
    }
}


private struct HeadlineView: View {
    let version: String
    let releaseDate: String
    init(_ version: String, releaseDate: String){
        self.version = version
        self.releaseDate = releaseDate
    }

    var body: some View {
        HStack{
            Text("ver \(version)")
                .font(.headline)
            Spacer()
            Text("\(releaseDate)配信")
                .font(.subheadline)
        }
        .padding(.bottom)
    }

}

private struct ParagraphView: View {
    let headline: String
    let points: [String]
    init(_ headline: String, points: [String]){
        self.headline = headline
        self.points = points
    }

    var body: some View {
        VStack(alignment: .leading){
            Text("・\(headline)")
            ForEach(points, id: \.self){point in
                Text(" - \(point)")
            }
        }
        .padding(.bottom, 1)
    }

}
