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
        Form{
            Section{
                KeyboardTypeSettingItemView(Store.shared.keyboardTypeSetting, language: .japanese).padding(.vertical)
                KeyboardTypeSettingItemView(Store.shared.englishKeyboardTypeSetting, language: .english).padding(.vertical)
            }
        }.navigationBarTitle(Text("キーボードの詳細設定"), displayMode: .inline)
    }
}
