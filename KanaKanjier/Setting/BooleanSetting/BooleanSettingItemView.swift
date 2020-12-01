//
//  BooleanSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/09.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI


struct BooleanSettingItemView: View {
    init(_ viewModel: SettingItemViewModel<Bool>){
        self.item = viewModel.item
        self.viewModel = viewModel
    }
    let item: SettingItem<Bool>
    @ObservedObject private var viewModel: SettingItemViewModel<Bool>

    var body: some View {
        HStack{
            Text(self.item.screenName)
            Spacer()
            Toggle(isOn: self.$viewModel.value) {
                EmptyView()
            }
            .toggleStyle(SwitchToggleStyle())
        }
    }
}
