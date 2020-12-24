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
                Text("azooKeyでは「テンプレート」という機能を使うことで、時刻や乱数などを用いた高度な変換を定義することが可能です。ここでは「2020/01/23 12:34」という形式のタイムスタンプを作ってみます。")
            }
            TipsContentParagraph{
                Text("テンプレートを作るには、まず「テンプレートの管理」から作成します。")
            }
            TipsContentParagraph{
                Text("ユーザ辞書で作成したテンプレートを使う際は、\(Text("{{テンプレート名}}").font(.system(.body, design: .monospaced)))という形式で記述します。")
            }
        }
    }
}
