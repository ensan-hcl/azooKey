//
//  UpdateInformationView.swift
//  MainApp
//
//  Created by ensan on 2020/12/03.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI
import SwiftUtils

struct UpdateInformationView: View {
    var body: some View {
        Form {
            // version 2系
            Group {
                // version 2.2系
                Group {
                    VersionView("2.2", releaseDate: "2023年10月xx日") {
                        if #unavailable(iOS 16) {
                            ParagraphView("お知らせ。") {
                                "バージョン2.3以降でiOS15のサポートを終了します。iOS16以上で引き続きご利用いただけます。ご不便をおかけしますが、よろしくお願いいたします"
                            }
                        }
                        ParagraphView("予測変換を大幅に強化しました。") {
                            "確定したあとに続けて打つ文字を予測するようになりました"
                            "より妥当な予測候補が表示されるようになりました"
                        }
                        ParagraphView("機能を改善しました。") {
                            "再変換を大幅に強化しました。"
                            "「連絡先」に登録されている氏名を読み込んで変換に利用できるようになりました"
                            "テキストを選択した際に表示していた「編集」機能を廃止しました"
                            "カーソルを動かした際、カーソルバーを表示するようにしました"
                            "カスタムキーで「次候補」と「A/a」の特殊キーを選べるようになりました"
                        }
                        ParagraphView("デザインを改善しました") {
                            "サジェストをよりはっきりと表示するようにしました"
                            "カーソルバーのデザインを改善しました"
                            "iPadでのデザインを改善しました"
                        }
                        ParagraphView("複数の不具合を修正しました。")
                        ParagraphView("その他辞書の改善を行いました。")
                    }
                }
                // version 2.1系
                Group {
                    VersionView("2.1.2", releaseDate: "2023年07月27日") {
                        ParagraphView("変換のパフォーマンスを大幅に改善しました。")
                        ParagraphView("不具合を修正しました。") {
                            "検索時などに「改行」キーの文字が変わらない問題を修正しました"
                            "「まるまん」などの特定の文字を入力した場合にキーボードがクラッシュする不具合を修正しました"
                        }
                        ParagraphView("その他辞書の軽微な改善を行いました。")
                    }
                    VersionView("2.1.1", releaseDate: "2023年04月17日") {
                        ParagraphView("新しい機能を追加しました。") {
                            "アプリ内で本体辞書への変換候補の追加を申請できるようになりました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "ローマ字入力で余計な文字が入力される不具合を修正しました"
                            "タブバーを変換候補欄の長押しで表示できない不具合を修正しました"
                            "辞書に不足していた単語を複数追加しました"
                        }
                    }
                    NavigationLink("変換候補の追加", destination: ShareWordView())
                    VersionView("2.1", releaseDate: "2023年04月09日") {
                        ParagraphView("新しい機能を追加しました。") {
                            "絵文字タブを追加しました"
                            "キーボードの高さを調整できるようになりました"
                        }
                        ParagraphView("フルアクセスの必要な機能を追加しました。") {
                            "一部の端末でキーの振動フィードバックが設定できるようになりました"
                            "ホームボタンのないiPhoneではペーストボタンが利用できるようになりました"
                            "クリップボードの履歴を保存しキーボード上で呼び出せるようになりました"
                            "変換候補を長押しして、誤変換を報告できるようになりました"
                        }
                        ParagraphView("機能を改善しました。") {
                            "「フリックで文頭まで削除」を利用したあと、一度だけ削除を取り消せるようになりました"
                            "片手モードの利用時に表示されるボタンを非表示にできるようになりました"
                            "変換候補を長押しして、学習をリセットできるようになりました"
                            "カスタムタブで「記号」タブのような二段のラベルが設定可能になりました"
                            "さまざまなUIのデザインを改善しました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "外部のカスタムタブを読み込む際、読み込みに失敗する不具合を修正しました"
                        }
                        ParagraphView("その他辞書の軽微な改善を行いました。")
                    }
                    NavigationLink("フルアクセスについて", destination: FullAccessTipsView())

                }
                // version 2.0系
                Group {
                    VersionView("2.0.3", releaseDate: "2023年02月27日") {
                        ParagraphView("不具合を修正しました。") {
                            "一部の一般的な単語が変換できない不具合を修正しました"
                            "学習のリセットが反映されない不具合を修正しました"
                            "学習データがごく稀に壊れる不具合を修正しました"
                        }
                    }
                    VersionView("2.0.2", releaseDate: "2023年02月22日") {
                        ParagraphView("機能を改善しました。") {
                            "iOS16.4以降で利用可能なUnicode15.0に対応した絵文字のデータを追加しました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "辞書データの不具合を修正し、変換が自然になりました"
                            "ローマ字入力の不具合を修正しました"
                            "「入力中のテキストを保護」の不具合を複数修正しました"
                            "OSのユーザ辞書を読み込んだあと、読み込みを解除できなくなる不具合を修正しました"
                        }
                    }
                    VersionView("2.0.1", releaseDate: "2023年02月10日") {
                        ParagraphView("不具合を修正しました。") {
                            "辞書データの不具合を修正し、変換が自然になりました"
                            "iPadのフローティングキーボードでazooKeyが使いやすくなりました"
                        }
                        ParagraphView("その他パフォーマンスの改善を行いました。")
                    }
                    VersionView("2.0", releaseDate: "2023年02月04日") {
                        ParagraphView("機能を改善しました。") {
                            "辞書データを大幅にアップデートしました"
                            "テンプレートをユーザ辞書上で編集できるようになりました"
                            "タブバーやカスタムキーにアクションを設定することで、キーボード上でショートカットを開けるようになりました"
                            "カスタムタブにおいて「透明」なキーを作成できるようになりました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "ライブ変換を使っていない場合に、一部のアプリケーションで入力がおかしくなる問題を修正"
                            "入力中の誤り訂正で濁点がつきすぎる問題を改善"
                        }
                        ParagraphView("お知らせ。") {
                            "azooKey 2.0はオープンソースソフトウェアになりました。ソースコードを誰でも閲覧し、利用することができます。ソースコードはGitHubで公開しています。"
                        }
                        ParagraphView("その他デザインの軽微な改善を行いました。")
                    }
                    FallbackLink("View azooKey on GitHub", destination: URL(string: "https://github.com/ensan-hcl/azooKey")!)
                }
            }
            // version 1系
            Group {
                // version 1.9系
                Group {
                    VersionView("1.9.3", releaseDate: "2022年11月12日") {
                        ParagraphView("不具合を修正しました。") {
                            "ライブ変換を使っていない場合に確定ボタンで確定した際、ひらがながカタカナとして学習されてしまう不具合を修正"
                            "カーソルの手動移動に関する不具合を修正"
                            "変換候補リストの更新が遅れる問題を修正"
                            "特定の手順で変換とカーソル移動を行うとキーボードがクラッシュする不具合を修正"
                        }
                    }
                    VersionView("1.9.2", releaseDate: "2022年11月10日") {
                        ParagraphView("仕様を変更しました。") {
                            "ご要望があったため、タブバーボタンの表示・非表示の切り替えを再び可能にしました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "設定を変更した後、表示が更新されないことがある不具合を修正"
                        }
                        ParagraphView("お知らせ。") {
                            "バージョン2.0以降でiOS14のサポートを終了します。iOS15以上で引き続きご利用いただけます。ご不便をおかけしますが、よろしくお願いいたします"
                        }
                    }
                    VersionView("1.9.1", releaseDate: "2022年11月01日") {
                        ParagraphView("不具合を修正しました。") {
                            "iPadOS 15で複数の日本語タブが存在する場合にキーボードの種類の選択ができなくなる問題を修正"
                        }
                    }
                    VersionView("1.9", releaseDate: "2022年10月31日") {
                        ParagraphView("学習機能を大幅に改善しました。") {
                            "学習結果がより長い期間にわたり維持されるようになりました"
                            "実験的な機能として、さらに長期間にわたって学習結果を維持するオプションも導入しました"
                        }
                        ParagraphView("ライトモードとダークモードで異なる着せ替えを設定できるようになりました。") {
                            "ダークモードに設定したい着せ替えを長押しし、「ダークモードで使用」を選択することで設定できます"
                        }
                        ParagraphView("フリック式のカスタムタブの編集機能を改善しました。") {
                            "編集中、キーのコピー・ペーストが可能になりました"
                            "編集中、行・列の挿入が可能になりました"
                            "編集中、行・列の削除が可能になりました"
                        }
                        ParagraphView("「入力中のテキストを保護」する機能を追加しました。") {
                            "この機能を有効化すると、一部のWebアプリでazooKeyの挙動が安定します"
                            "実験的な機能であり、不具合があったり挙動に変更があったりする可能性があります"
                        }
                        ParagraphView("新しいカーソルバーのベータ版を追加しました。") {
                            "より快適なカーソル移動のため、新しいカーソルバーを開発しました"
                            "カーソル周辺のテキストがキーボード上に表示されるので、直感的なカーソル移動が可能です"
                            "実験的な機能であり、不具合があったり挙動に変更があったりする可能性があります"
                            "フィードバックを募集します"
                        }
                        ParagraphView("その他の機能を改善しました。") {
                            "キーボードを開く・閉じる操作を繰り返すと動作が重くなっていた問題を修正"
                            "着せ替えの利用時に変換候補の拡大表示ボタンが押しにくくなる問題を修正"
                            "ローマ字入力のカスタムキーの設定でカスタムキーを削除しようとするとアプリが異常終了する問題を修正"
                            "スクロール式のカスタムタブで誤反応が起こる問題を修正"
                            "よく使われる記号の入力・変換に関連する機能を大幅に改善"
                            "ローマ字入力のさまざまな不具合を修正"
                            "ローマ字入力のパフォーマンスが向上"
                            "カスタムタブにおいて複数のアクションを連続して実行する場合のパフォーマンスが向上"
                            "より多くのケースで再変換が可能に"
                            "数値を入力するテキストフィールドで数字専用キーボードが表示されるように変更"
                        }
                        ParagraphView("その他デザイン・辞書の軽微な改善を行いました。")
                    }
                }
                // version 1.8系
                Group {
                    VersionView("1.8.1", releaseDate: "2022年09月20日") {
                        ParagraphView("不具合を修正しました。") {
                            "iOS 15でデバイスの回転が正しく行えなくなる問題を修正"
                            "再変換機能が不具合を起こす可能性がある問題を修正"
                        }
                    }
                    VersionView("1.8", releaseDate: "2022年09月19日") {
                        ParagraphView("機能を追加しました。") {
                            "フリック感度の調整機能を追加"
                            "ライブ変換中の「自動確定」機能を追加"
                        }
                        ParagraphView("機能を改善しました。") {
                            "iOS 16に正式に対応しました"
                            "辞書データを大幅にアップデートしました"
                            "ライブ変換の不具合を複数修正しました"
                        }
                        ParagraphView("既知の不具合。") {
                            "iPadOS 16以降のiPad Proで「スペースを拡大」の設定を有効化している場合、キーボードの左側に大きな隙間が現れる問題が生じています。原因は調査中です"
                        }
                        ParagraphView("その他デザインの軽微な改善を行いました。")
                    }
                }
                // version 1.7系
                Group {
                    VersionView("1.7.2", releaseDate: "2022年07月03日") {
                        ParagraphView("不具合を修正しました。") {
                            "誤った変換候補が頻繁に現れる問題の修正"
                        }
                    }
                    VersionView("1.7.1", releaseDate: "2022年07月02日") {
                        ParagraphView("不具合を修正しました。") {
                            "着せ替えのシェア機能がiOS15で正しく動作しない問題を修正"
                            "お知らせメッセージが正しく表示されない問題を修正"
                        }
                        ParagraphView("その他デザイン・辞書の軽微な改善を行いました。")
                    }
                    VersionView("1.7", releaseDate: "2022年05月06日") {
                        ParagraphView("機能を追加しました。") {
                            "ライブ変換が設定できるようになりました"
                            "一部のケースで再変換が可能になりました"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "一部環境でQwertyキーボードの着せ替えができない問題を修正"
                            "特定の条件でカスタムキーの編集が反映されない問題を修正"
                        }
                        ParagraphView("機能を改善しました。") {
                            "iOS15.4以降で利用可能なUnicode14.0に対応した絵文字のデータを追加"
                            "辞書データを大幅にアップデートしました"
                        }
                        ParagraphView("その他デザイン・パフォーマンスの軽微な改善を行いました。")
                    }
                }
                // version 1.6系
                Group {
                    VersionView("1.6.2", releaseDate: "2021年09月06日") {
                        ParagraphView("カスタムタブ機能を改善しました。") {
                            "タブバー表示ボタンを追加"
                        }
                        ParagraphView("iOS15に対応しました。") {
                            "挙動の変更によって動かなくなった機能を修正"
                        }
                    }
                    VersionView("1.6.1", releaseDate: "2021年04月27日") {
                        ParagraphView("カスタムタブ機能を改善しました。") {
                            "フリック入力できるカスタムタブを作成する機能を追加"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "着せ替え機能で色を変更してもカラーピッカーの表示が変化しない問題を修正"
                            "iOS14.5で追加された絵文字を入力できない問題を修正"
                        }
                        ParagraphView("その他デザイン・変換機能の軽微な改善を行いました。")
                    }
                    VersionView("1.6", releaseDate: "2021年03月29日") {
                        ParagraphView("カスタムタブ機能を追加しました。") {
                            "オリジナルのタブを作成できるカスタムタブ機能の導入"
                            "カスタムタブへの移動を担う「タブバー」の導入"
                            "外部で作成したカスタムタブを読み込む機能を追加"
                            "読み込んだカスタムタブをデフォルトの日本語・英語タブに設定する機能"
                        }
                        ParagraphView("機能を改善しました。") {
                            "片手モードの追加"
                            "iOS14.5以降で利用可能なUnicode13.1に対応した絵文字のデータを追加"
                            "カスタムキーに入力以外の操作を割り当てる機能を追加"
                            "フリックカスタムキーに長押し・長フリックの際の操作を割り当てる機能を追加"
                            "フリック入力で3つのタブ移動キーをカスタマイズする機能を追加"
                            "キーボードを日本語のみ・英語のみで利用する設定を追加"
                            "着せ替え機能で変換候補の背景色を設定する機能を追加"
                            "ほとんどの機能を英語対応"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "着せ替え機能で枠線を設定してもサジェストに反映されない問題を修正"
                        }
                        ParagraphView("その他デザイン・変換機能・パフォーマンスの軽微な改善を行いました。")
                    }
                }
                // version 1.5系
                Group {
                    VersionView("1.5.1", releaseDate: "2021年02月15日") {
                        ParagraphView("機能を改善しました。") {
                            "一部機能を英語対応"
                        }
                    }
                    VersionView("1.5", releaseDate: "2021年02月14日") {
                        ParagraphView("機能を追加しました。") {
                            "着せ替え機能を追加"
                            "端末の標準のユーザ辞書を読み込む設定を追加"
                            "URL scheme(azooKey://)に対応"
                        }
                        ParagraphView("機能を改善しました。") {
                            "パフォーマンスの改善"
                            "ローマ字キーボードで大文字に固定した際、キーボードの文字も大文字になるように変更"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "文章を選択中、削除キーを二度押さないと削除ができない問題"
                        }
                        ParagraphView("その他デザイン・変換機能・操作性の軽微な改善を行いました。")
                    }
                }
                // version 1.4系
                Group {
                    VersionView("1.4.4", releaseDate: "2021年01月30日") {
                        ParagraphView("不具合を修正しました。") {
                            "テンプレートの編集が完了できないことがある不具合"
                        }
                    }
                    VersionView("1.4.3", releaseDate: "2021年01月18日") {
                        ParagraphView("不統一なデザインを修正しました。")
                        ParagraphView("辞書を更新しました。")
                    }
                    VersionView("1.4.2", releaseDate: "2021年01月08日") {
                        ParagraphView("不具合を修正しました。") {
                            "キーボードの種類の変更が反映されない事がある問題"
                        }
                    }
                    VersionView("1.4.1", releaseDate: "2021年01月06日") {
                        ParagraphView("軽微な不具合を修正しました。")
                    }
                    VersionView("1.4", releaseDate: "2021年01月05日") {
                        ParagraphView("機能を追加しました。") {
                            "日付や時刻の入力やランダムな変換を可能にする「テンプレート」機能を追加"
                            "フリック入力で「､｡!?」キーをカスタマイズする機能を追加"
                            "全角英数字の変換候補を表示する設定を追加"
                        }
                        ParagraphView("機能を改善しました。") {
                            "日本語入力と英語入力それぞれでキーボードの種類を選択できるように変更"
                            "フリックカスタムキーの編集画面を一新"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "フリック/ローマ字入力方式の切り替え直後にキーボードがクラッシュする問題"
                            "ローマ字入力で正しく入力できない文字がある問題"
                        }
                        ParagraphView("その他軽微なデザイン・変換機能・操作性の改善を行いました。")
                    }
                }
                // version 1.3系
                Group {
                    VersionView("1.3.1", releaseDate: "2020年12月18日") {
                        ParagraphView("不具合を修正しました。") {
                            "iPhone X以降の端末で一部キーが反応しない問題"
                        }
                    }
                    VersionView("1.3", releaseDate: "2020年12月15日") {
                        ParagraphView("機能を追加しました。") {
                            "英語入力中、大文字に固定する機能を追加"
                            "ローマ字での日本語入力中、英語への変換を表示する機能のON/OFF設定を追加"
                        }
                        ParagraphView("機能を改善しました。") {
                            "ローマ字カスタムキーの編集画面を一新"
                        }
                        ParagraphView("技術的に解決困難な不具合のため、文字数カウント機能を削除しました。") {
                            "今後別の形でのカウント機能の実装を検討します"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "ローマ字での日本語入力中、一部の入力が正しく反映されない問題"
                        }
                        ParagraphView("記号の変換を改善しました。")
                        ParagraphView("その他軽微なデザイン・変換機能の改善を行いました。")
                    }
                }
                // version 1.2系
                Group {
                    VersionView("1.2.1", releaseDate: "2020年12月10日") {
                        ParagraphView("不具合を修正しました。") {
                            "ローマ字カスタムキーの編集で削除ができなくなる問題"
                        }
                    }

                    VersionView("1.2", releaseDate: "2020年12月09日") {
                        ParagraphView("機能を追加しました。") {
                            "azooKeyユーザ辞書機能を追加"
                            "キーの文字サイズを変更する機能を追加"
                            "ローマ字での日本語入力中、英単語の変換候補も表示するよう変更"
                        }
                        ParagraphView("不具合を修正しました。") {
                            "ローマ字での英語入力中、一部の候補を選択した場合に正しく変換されない問題"
                        }
                        ParagraphView("記号の変換を改善しました。")
                        ParagraphView("その他軽微なデザイン・操作性の改善を行いました。")
                    }
                }
                VersionView("1.1", releaseDate: "2020年12月06日") {
                    ParagraphView("機能を改善しました。") {
                        "ローマ字入力中の矢印入力に対応"
                        "unicode変換の接頭辞を拡大"
                        "数字の装飾文字変換に対応"
                    }
                    ParagraphView("次の問題を修正しました。") {
                        "一部候補が正しく学習されない問題"
                        "ローマ字入力中の変換の不具合"
                    }
                    ParagraphView("その他軽微なデザインの修正を行いました。")
                }

                VersionView("1.0", releaseDate: "2020年12月04日") {
                    ParagraphView("azooKeyを公開しました。")
                }
            }
        }.navigationBarTitle(Text("更新履歴"), displayMode: .inline)
    }
}

private struct HeadlineView: View {
    private let version: String
    private let releaseDate: String
    init(_ version: String, releaseDate: String) {
        self.version = version
        self.releaseDate = releaseDate
    }

    var body: some View {
        HStack(alignment: .bottom) {
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
    private let headline: String
    private let points: () -> [String]

    init(_ headline: String, @ArrayBuilder points: @escaping () -> [String] = {return [String]()}) {
        self.headline = headline
        self.points = points
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("⚫︎\(headline)").bold()
            let allPoints = points()
            ForEach(allPoints.indices, id: \.self) {i in
                Text("・\(allPoints[i])")
            }
        }
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
        .padding(.bottom, 3)
    }

}

private struct VersionView<Content: View>: View {
    private let content: () -> Content

    private let version: String
    private let releaseDate: String

    init(_ version: String, releaseDate: String, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.version = version
        self.releaseDate = releaseDate
    }

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HeadlineView(version, releaseDate: releaseDate)
                Divider()
                content()
            }
            .multilineTextAlignment(.leading)
        }
    }

}
