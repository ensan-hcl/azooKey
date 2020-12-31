//
//  UpdateInfomationView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI
struct UpdateInfomationView: View {
    var body: some View {
        Form{
            VersionView("1.4", releaseDate: "2021年01月xx日"){
                ParagraphView("機能を追加しました。"){
                    "日付や時刻の入力やランダムな変換を可能にする「テンプレート」機能を追加"
                    "フリック入力で「､｡!?」キーをカスタマイzスする機能を追加"
                    "全角英数字の変換候補を表示する設定を追加"
                }
                ParagraphView("機能を改善しました。"){
                    "日本語入力と英語入力それぞれでキーボードの種類を選択できるように変更"
                    "フリックカスタムキーの編集画面を一新"
                }
                ParagraphView("不具合を修正しました。"){
                    "フリック/ローマ字入力方式の切り替え直後にキーボードがクラッシュする問題"
                    "ローマ字入力で正しく入力できない文字がある問題"
                }
                ParagraphView("その他軽微なデザイン・変換機能の改善を行いました。")
            }
            VersionView("1.3.1", releaseDate: "2020年12月18日"){
                ParagraphView("不具合を修正しました。"){
                    "iPhone X以降の端末で一部キーが反応しない問題"
                }
            }
            VersionView("1.3", releaseDate: "2020年12月15日"){
                ParagraphView("機能を追加しました。"){
                    "英語入力中、大文字に固定する機能を追加"
                    "ローマ字での日本語入力中、英語への変換を表示する機能のON/OFF設定を追加"
                }
                ParagraphView("機能を改善しました。"){
                    "ローマ字カスタムキーの編集画面を一新"
                }
                ParagraphView("技術的に解決困難な不具合のため、文字数カウント機能を削除しました。"){
                    "今後別の形でのカウント機能の実装を検討します。"
                }
                ParagraphView("不具合を修正しました。"){
                    "ローマ字での日本語入力中、一部の入力が正しく反映されない問題"
                }
                ParagraphView("記号の変換を改善しました。")
                ParagraphView("その他軽微なデザイン・変換機能の改善を行いました。")
            }

            VersionView("1.2.1", releaseDate: "2020年12月10日"){
                ParagraphView("不具合を修正しました。"){
                    "ローマ字カスタムキーの編集で削除ができなくなる問題"
                }
            }

            VersionView("1.2", releaseDate: "2020年12月09日"){
                ParagraphView("機能を追加しました。"){
                    "azooKeyユーザ辞書機能を追加"
                    "キーの文字サイズを変更する機能を追加"
                    "ローマ字での日本語入力中、英単語の変換候補も表示するよう変更"
                }
                ParagraphView("不具合を修正しました。"){
                    "ローマ字での英語入力中、一部の候補を選択した場合に正しく変換されない問題"
                }
                ParagraphView("記号の変換を改善しました。")
                ParagraphView("その他軽微なデザイン・操作性の改善を行いました。")
            }

            VersionView("1.1", releaseDate: "2020年12月06日"){
                ParagraphView("機能を改善しました。"){
                    "ローマ字入力中の矢印入力に対応"
                    "unicode変換の接頭辞を拡大"
                    "数字の装飾文字変換に対応"
                }
                ParagraphView("次の問題を修正しました。"){
                    "一部候補が正しく学習されない問題"
                    "ローマ字入力中の変換の不具合"
                }
                ParagraphView("その他軽微なデザインの修正を行いました。")
            }

            VersionView("1.0", releaseDate: "2020年12月04日"){
                ParagraphView("azooKeyを公開しました。")
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
    let points: () -> [String]

    init(_ headline: String, @ArrayBuilder<String> points: @escaping () -> [String] = {return [String]()}){
        self.headline = headline
        self.points = points
    }

    var body: some View {
        VStack(alignment: .leading){
            Text("⚫︎\(headline)").bold()
            let allPoints = points()
            ForEach(allPoints.indices, id: \.self){i in
                Text("・\(allPoints[i])")
            }
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)

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
                Divider()
                content()
            }
            .multilineTextAlignment(.leading)
        }
    }

}
