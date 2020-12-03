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
    @State private var isOn = false

    var body: some View {
        HStack{
            Text(self.item.screenName)
            Button{
                isOn = true
            }label: {
                Image(systemName: "info.circle")
            }
            Spacer()
            Toggle(isOn: self.$viewModel.value) {
                EmptyView()
            }
            .toggleStyle(SwitchToggleStyle())
            .alert(isPresented: $isOn){
                Alert(title: Text(self.item.description), dismissButton: .default(Text("OK"), action: {
                    isOn = false
                }))
            }
        }
    }
}
