//
//  FontSizeSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//


import SwiftUI

struct FontSizeSettingItemView: View {
    let availableValues: [FontSizeSetting]
    typealias ItemViewModel = SettingItemViewModel<FontSizeSetting>
    typealias ItemModel = SettingItem<FontSizeSetting>

    init(_ viewModel: ItemViewModel, availableValues: [FontSizeSetting]){
        self.item = viewModel.item
        self.viewModel = viewModel
        self.availableValues = availableValues
    }
    
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    @State private var isOn = false

    var body: some View {
        HStack{
            VStack{
                HStack{
                    Text(self.item.screenName)
                    Button{
                        isOn = true
                    }label: {
                        Image(systemName: "info.circle")
                    }
                }
                Text("サンプル")
                    .font(.system(size: CGFloat(viewModel.value.saveValue == -1 ? 18 : CGFloat(viewModel.value.saveValue))))
                    .underline()
            }
            Spacer()
            Picker(selection: $viewModel.value, label: Text("")) {
                ForEach(self.availableValues) {data in
                    Text("\(data.description)").tag(data)
                }
            }
            .labelsHidden()
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100, height: 70)
            .clipped()

        }.frame(maxWidth: .infinity)
        .alert(isPresented: $isOn){
            Alert(title: Text(self.item.description), dismissButton: .default(Text("OK"), action: {
                isOn = false
            }))
        }

    }

}
