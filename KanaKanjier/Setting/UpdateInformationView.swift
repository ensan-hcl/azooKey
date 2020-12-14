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
            VersionView("1.3", releaseDate: "2020年12月xx日"){
                ParagraphView("機能を追加しました。", points: [
                    "英語入力中、大文字に固定する機能を追加",
                    "ローマ字での日本語入力中、英語への変換を表示する機能のON/OFF設定を追加",
                ])
                ParagraphView("機能を改善しました。", points: [
                    "ローマ字カスタムキーの編集画面を一新",
                ])
                ParagraphView("技術的に解決困難な不具合のため、文字数カウント機能を削除しました。", points: [
                    "今後別の形でのカウント機能の実装を検討します。"
                ])
                ParagraphView("不具合を修正しました。", points: [
                    "ローマ字での日本語入力中、一部の入力が正しく反映されない問題",
                ])
                ParagraphView("記号の変換を改善しました。", points: [])
                ParagraphView("その他軽微なデザイン・変換機能の改善を行いました。", points: [])
            }

            VersionView("1.2.1", releaseDate: "2020年12月10日"){
                ParagraphView("不具合を修正しました。", points: [
                    "ローマ字カスタムキーの編集で削除ができなくなる問題",
                ])
            }

            VersionView("1.2", releaseDate: "2020年12月09日"){
                ParagraphView("機能を追加しました。", points: [
                    "azooKeyユーザ辞書機能を追加",
                    "キーの文字サイズを変更する機能を追加",
                    "ローマ字での日本語入力中、英単語の変換候補も表示するよう変更",
                ])
                ParagraphView("不具合を修正しました。", points: [
                    "ローマ字での英語入力中、一部の候補を選択した場合に正しく変換されない問題",
                ])
                ParagraphView("記号の変換を改善しました。", points: [])
                ParagraphView("その他軽微なデザイン・操作性の改善を行いました。", points: [])
            }

            VersionView("1.1", releaseDate: "2020年12月06日"){
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

            VersionView("1.0", releaseDate: "2020年12月04日"){
                ParagraphView("azooKeyを公開しました。", points: [])
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
        HStack(alignment: .bottom){
            Text("ver \(version)")
                .font(.title2)
            Spacer()
            Text("\(releaseDate)配信")
                .font(.subheadline)
        }
        .padding(2)
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
            Text("⚫︎\(headline)")
            if !points.isEmpty{
                Text(points.map{"・\($0)"}.joined(separator: "\n"))
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.bottom, 3)
    }

}

private struct VersionView<Content: View>: View {
    private let content: () -> Content

    private let version: String
    private let releaseDate: String

    init(_ version: String, releaseDate: String, @ViewBuilder _ content: @escaping () -> Content){
        self.content = content
        self.version = version
        self.releaseDate = releaseDate
    }

    var body: some View {
        Section{
            VStack(alignment: .leading){
                HeadlineView(version, releaseDate: releaseDate)
                content()
            }
            .multilineTextAlignment(.leading)
        }
    }

}
