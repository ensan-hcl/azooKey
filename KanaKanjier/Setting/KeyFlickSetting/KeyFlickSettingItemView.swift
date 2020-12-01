//
//  SettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/16.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct KeyFlickSettingItemView: View {
    typealias ItemViewModel = SettingItemViewModel<KeyFlickSetting>
    typealias ItemModel = SettingItem<KeyFlickSetting>

    init(_ viewModel: ItemViewModel){
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    
    
    private let types = KeyboardType.allCases

    // TODO: 可能になったタイミングでReturnKeyTypeを設定する
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "arrow.left")
                Text("左フリック")
                TextField("入力する文字", text: $viewModel.value.left)
            }
            HStack{
                Image(systemName: "arrow.up")
                Text("上フリック")
                TextField("入力する文字", text: $viewModel.value.top)
            }
            HStack{
                Image(systemName: "arrow.right")
                Text("右フリック")
                TextField("入力する文字", text: $viewModel.value.right)
            }

        }
    }
}
