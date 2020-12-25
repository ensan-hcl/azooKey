//
//  TemplateSettingTipsView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TemplateSettingTipsView: View {
    var body: some View {
        TipsContentView("タイムスタンプを設定する"){
            TipsContentParagraph{
                Text("azooKeyでは「テンプレート」という機能を使うことで、時刻や乱数などを用いた高度な変換を定義することが可能です。ここでは「2020/01/23 01:23」という形式のタイムスタンプを作ってみます。")
            }
            TipsContentParagraph{
                Text("テンプレートを作るには、まず「テンプレートの管理」から作成します。画面右上の\(systemImage: "plus", color: .accentColor)を押して、テンプレートを追加しましょう。")
                TipsImage("templateSettingTips_1")
            }
            TipsContentParagraph{
                Text("追加したテンプレートを選ぶと編集画面が開きます。")
                Text("編集画面で次のように設定します。")
                Text("・名前を「タイムスタンプ」に設定")
                Text("・書式で「カスタム」を選択")
                Text("・カスタム書式に「yyyy/MM/dd hh:mm」と入力")
                TipsImage("templateSettingTips_2")
                Text("編集が終わったら完了ボタンを押してください。")
            }

            TipsContentParagraph{
                Text("次にユーザ辞書でテンプレートを使います。「追加する」から新規に単語を登録し、編集画面が開きます。")
                Text("ユーザ辞書で作成したテンプレートを使う際は、\(monospaced: "{{テンプレート名}}")という形式で記述します。")
                Text("今回は「タイムスタンプ」というテンプレートなので、\(monospaced: "{{タイムスタンプ}}")と入力します。")
                TipsImage("templateSettingTips_3")
                Text("編集が終わったら完了ボタンを押してください。")
            }

            TipsContentParagraph{
                Text("以上で設定が完了です。あとは実際に使ってみましょう。")
                TipsImage("templateSettingTips_4")
            }

            TipsContentParagraph{
                Text("azooKeyではこの他にも、「ズレ」を設定することで昨日や明日の日付を表示したり、乱数を用いるテンプレートを設定したりすることができます。")
            }

        }
    }
}
