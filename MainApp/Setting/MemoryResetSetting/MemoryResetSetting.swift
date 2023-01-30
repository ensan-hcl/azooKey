//
//  MemoryResetSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/24.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct MemoryResetSettingItemView: View {
    @State private var showAlert = false

    var body: some View {
        Button("学習のリセット") {
            self.showAlert = true
        }
        .foregroundColor(.red)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("学習履歴をリセットします。よろしいですか？"),
                message: Text("この操作は取り消せません。"),
                primaryButton: .cancel(Text("キャンセル"), action: {
                    self.showAlert = false
                }),
                secondaryButton: .destructive(Text("リセットする"), action: {
                    MemoryResetCondition.set(value: .need)
                    self.showAlert = false
                })
            )
        }
    }
}
