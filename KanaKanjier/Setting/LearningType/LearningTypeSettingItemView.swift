//
//  LearningTypeSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct LearningTypeSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<LearningType>
    typealias ItemModel = SettingItem<LearningType>

    init(_ viewModel: ItemViewModel) {
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    private let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    @State private var selection = 0    // 選択値と連携するプロパティ

    var body: some View {
        HStack {
            Text(self.item.identifier.title)
            Spacer()
            Picker(selection: $viewModel.value, label: Text("")) {
                ForEach(0 ..< LearningType.allCases.count) { i in
                    Text(LearningType.allCases[i].string).tag(LearningType.allCases[i])
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
