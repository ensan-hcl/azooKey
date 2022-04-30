//
//  KeyboardLayoutTypeDetailsView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyboardLayoutTypeDetailsView: View {
    var body: some View {
        Form {
            Section {
                Text("macOSなどに搭載されている、入力中の文字列を自動的に変換する「ライブ変換」が利用できます。") // TODO: Localize
                BoolSettingView(.liveConversion)
            }
            Section {
                LanguageLayoutSettingView(.japaneseKeyboardLayout, language: .japanese).padding(.vertical)
                LanguageLayoutSettingView(.englishKeyboardLayout, language: .english).padding(.vertical)
            }
        }.navigationBarTitle(Text("キーボードの入力方式"), displayMode: .inline)
    }
}
