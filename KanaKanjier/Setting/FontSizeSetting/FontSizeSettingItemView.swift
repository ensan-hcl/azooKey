//
//  FontSizeSettingItemView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//


import SwiftUI

struct FontSizeSettingItemView: View {
    enum Target{
        case key
        case result
    }

    let availableValues: [FontSizeSetting]
    let target: Target

    typealias ItemViewModel = SettingItemViewModel<FontSizeSetting>
    typealias ItemModel = SettingItem<FontSizeSetting>

    init(_ viewModel: ItemViewModel, _ target: Target, availableValues: [FontSizeSetting]){
        self.item = viewModel.item
        self.viewModel = viewModel
        self.target = target
        self.availableValues = availableValues
    }
    
    let item: ItemModel
    @ObservedObject private var viewModel: ItemViewModel
    @State private var isOn = false

    var body: some View {
        HStack{
            VStack{
                HStack{
                    Text(self.item.identifier.title)
                    Button{
                        isOn = true
                    }label: {
                        Image(systemName: "info.circle")
                    }
                }
                let size = CGFloat(viewModel.value.saveValue == -1 ? 18 : viewModel.value.saveValue)
                switch self.target{
                case .key:
                    KeyView(fontSize: size)
                    
                case .result:
                    Text("サンプル")
                        .font(.system(size: size))
                        .underline()
                        .padding()
                }
            }
            Spacer()
            Picker(selection: $viewModel.value, label: Text("")) {
                ForEach(self.availableValues) {data in
                    Text(data.display).tag(data)
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
struct KeyView: View {
    @ObservedObject private var storeVariableSection = Store.variableSection
    let fontSize: CGFloat

    init(fontSize: CGFloat){
        self.fontSize = fontSize
    }

    var size: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch storeVariableSection.japaneseLayout{
        case .flick:
            return CGSize(width: screenWidth/5.6, height: screenWidth/8)
        case .qwerty:
            return CGSize(width: screenWidth/12.2, height: screenWidth/9)
        case .custard:
            return CGSize(width: screenWidth/5.6, height: screenWidth/8)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke()
            .frame(width: size.width, height: size.height)
            .overlay(Text("あ").font(.system(size: fontSize)))
    }
}
