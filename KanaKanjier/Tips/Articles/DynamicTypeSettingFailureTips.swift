//
//  DynamicTypeSettingFailureTips.swift
//  KanaKanjier
//
//  Created by β α on 2020/10/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct DynamicTypeSettingFailureTipsView: View {
    var body: some View {
        TipsContentView("端末の文字サイズ設定が反映されない") {
            TipsContentParagraph {
                Text("端末の文字サイズの設定を変更しても、キーボードに表示される文字の大きさが変わらないことがあります。")
                Text("一度端末を再起動していただくと設定が反映されます。")
            }
            
            TipsContentParagraph {
                Text("azooKeyの設定タブよりキーの文字サイズを設定することが可能です。そちらもお試しください。")
            }
            
        }
    }
}
