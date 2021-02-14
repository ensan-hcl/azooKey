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
                KeyboardLayoutSettingItemView(Store.shared.keyboardTypeSetting, language: .japanese, id: 10).padding(.vertical)
                KeyboardLayoutSettingItemView(Store.shared.englishKeyboardTypeSetting, language: .english, id: 20).padding(.vertical)
            }
        }.navigationBarTitle(Text("キーボードの入力方式"), displayMode: .inline)
    }
}
