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
                LanguageLayoutSettingItemView(Store.shared.japaneseLayoutSetting, language: .japanese).padding(.vertical)
                LanguageLayoutSettingItemView(Store.shared.englishLayoutSetting, language: .english).padding(.vertical)
            }
        }.navigationBarTitle(Text("キーボードの入力方式"), displayMode: .inline)
    }
}
