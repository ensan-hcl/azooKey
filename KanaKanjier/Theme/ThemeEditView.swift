//
//  ThemeEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/07.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import PhotosUI

struct ThemeEditView: View {
    @State private var theme: ThemeData = ThemeData.default
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectFontRowValue: Double = 4

    init(){
        VariableStates.shared.themeManager.theme = self.theme
        VariableStates.shared.keyboardLayout = SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout)
    }

    @State private var image: UIImage? = nil
    @State private var isPhotoPickerPresented = false

    // PHPickerの設定
    var config: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    @State private var useImage = false
    @State private var refresh = false

    var body: some View {
        VStack{
            Form{
                Section(header: Text("背景")){
                    if let _ = image{
                        Button{
                            self.isPhotoPickerPresented = true
                        } label: {
                            HStack{
                                Text("\(systemImage: "photo")画像を選び直す")
                            }
                        }

                        Button{
                            image = nil
                        } label: {
                            HStack{
                                Text("画像を削除")
                            }
                        }
                    } else {
                        Button{
                            self.isPhotoPickerPresented = true
                        } label: {
                            HStack{
                                Text("\(systemImage: "photo")画像を選ぶ")
                            }
                        }
                        ColorPicker("背景の色", selection: $theme.backgroundColor)
                    }
                }
                Section(header: Text("文字")){
                    HStack{
                        Text("文字の太さ")
                        Slider(value: $selectFontRowValue, in: 1...9.9){editing in
                            theme.textFont = ThemeFontWeight.init(rawValue: Int(selectFontRowValue)) ?? .regular
                        }
                    }
                }

                Section(header: Text("キー")){
                    ColorPicker("キーの文字の色", selection: $theme.textColor)

                    ColorPicker("通常キーの背景色", selection: $theme.borderColor)
                    ColorPicker("特殊キーの背景色", selection: $theme.borderColor)

                    ColorPicker("枠線の色", selection: $theme.borderColor)
                    HStack{
                        Text("枠線の太さ")
                        Slider(value: $theme.borderWidth, in: 0...10)
                    }
                }

                Section(header: Text("変換候補")){
                    ColorPicker("変換候補の文字の色", selection: $theme.resultTextColor)
                }

                Section{
                    Button{
                        self.theme = .default
                    } label: {
                        Text("リセットする")
                            .foregroundColor(.red)
                    }
                }

            }
            if refresh{
                KeyboardPreview()
                    .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                    .clipped()
                    .scaleEffect(0.9, anchor: .center)
            }else{
                KeyboardPreview()
                    .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                    .clipped()
                    .scaleEffect(0.9, anchor: .center)
            }
        }
        .background(backgroundColor)
        .onChange(of: image){value in
            if let value = value{
                self.theme.picture = .uiImage(value)
                self.theme.backgroundColor = Color.white.opacity(0)
            }else{
                self.theme.picture = .none
            }

        }
        .onChange(of: theme){value in
            VariableStates.shared.themeManager.theme = self.theme
            self.refresh.toggle()
        }
        .sheet(isPresented: $isPhotoPickerPresented){
            PhotoPicker(configuration: self.config,
                        pickerResult: $image,
                        isPresented: $isPhotoPickerPresented)
        }
        .navigationBarTitle(Text("着せ替えの編集"), displayMode: .inline)
    }

    var backgroundColor: Color {
        switch colorScheme{
        case .light:
            return Color.systemGray6
        case .dark:
            return Color.black
        @unknown default:
            return Color.systemGray6
        }
    }
}
