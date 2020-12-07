//
//  CursorMoveTips.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct CursorMoveTipsView: View {
    var body: some View {
        TipsContentView("カーソルを移動する"){
            TipsContentParagraph{
                Text("「空白」を長押しすると、カーソル移動ボタンが現れます。ホームボタンのない端末のフリック入力では左下の\(Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"))を押して表示することも可能です。")
                TipsImage("moveCursor")
            }
            
            TipsContentParagraph{
                Text("\(Text("黄色枠").foregroundColor(.orange))\(Image(systemName: "circle.fill"))部分に指を置いて左右になぞることでカーソルが滑らかに移動します。")
                Text("1文字ずつ移動したい場合は\(Text("青枠").foregroundColor(.blue))の\(Image(systemName: "chevron.left.2"))部分または\(Image(systemName: "chevron.right.2"))部分をタップすることでそれぞれの方向に1文字ずつ移動します。")
                Text("カーソル移動ボタンを消すには、入力/削除を行うか、再び空白を長押ししてください。")
            }
        }
    }
}
