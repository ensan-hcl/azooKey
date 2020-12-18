//
//  File.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct KeyboardTypeSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<KeyboardType>
    typealias ItemModel = SettingItem<KeyboardType>

    init(_ viewModel: ItemViewModel){
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel

    private let types = KeyboardType.allCases
    var imageName:String{
        Store.variableSection.KeyboardType = types[viewModel.value.id]
        return types[viewModel.value.id].imageName
    }

    var body: some View {
        VStack{
            Text(self.item.identifier.title + "(現在: \(viewModel.value.string))")
            CenterAlignedView{
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: Store.shared.imageMaximumWidth)
            }
            Picker(selection: $viewModel.value, label: Text("キーボードの種類")) {
                ForEach(0 ..< types.count) { i in
                    Text(types[i].string).tag(types[i])
                }
            }
            .pickerStyle(SegmentedPickerStyle())    // セグメントピッカースタイルの指定
        }
    }
}

