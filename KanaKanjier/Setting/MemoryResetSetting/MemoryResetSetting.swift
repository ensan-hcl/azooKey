//
//  MemoryResetSetting.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/24.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct MemoryResetSettingItemView: View {
    init(_ viewModel: SettingItemViewModel<MemoryResetCondition>) {
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    private let item: SettingItem<MemoryResetCondition>
    @ObservedObject private var viewModel: SettingItemViewModel<MemoryResetCondition>
    @State private var showAlert = false

    var body: some View {
        Button {
            self.showAlert = true
        }label: {
            HStack {
                Text(self.item.identifier.title)
                    .foregroundColor(.primary)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("学習履歴をリセットします。よろしいですか？"),
                message: Text("この操作は取り消せません。"),
                primaryButton: .cancel(Text("キャンセル"), action: {
                    self.showAlert = false
                }),
                secondaryButton: .destructive(Text("リセットする"), action: {
                    self.viewModel.value = .need
                    self.showAlert = false
                })
            )
        }
    }
}
