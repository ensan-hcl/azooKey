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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var selectFontRowValue: Double = 4

    init(){
        VariableStates.shared.themeManager.theme = self.theme
        self.theme.suggestKeyFillColor = .color(Color.init(white: 1))
        VariableStates.shared.keyboardLayout = SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout)
    }

    @State private var image: UIImage? = nil
    @State private var isPhotoPickerPresented = false

    @State private var normalKeyColor = Design.colors.normalKeyColor
    @State private var specialKeyColor = Design.colors.specialKeyColor

    // PHPickerの設定
    var config: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    @State private var refresh = false

    //キャプチャ用
    @State private var captureRect: CGRect = .zero

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
                                    .foregroundColor(.red)
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

                Section(header: Text("変換候補")){
                    ColorPicker("変換候補の文字の色", selection: $theme.resultTextColor)
                }

                Section(header: Text("キー")){
                    ColorPicker("キーの文字の色", selection: $theme.textColor)

                    ColorPicker("通常キーの背景色", selection: $normalKeyColor)
                    ColorPicker("特殊キーの背景色", selection: $specialKeyColor)

                    ColorPicker("枠線の色", selection: $theme.borderColor)
                    HStack{
                        Text("枠線の太さ")
                        Slider(value: $theme.borderWidth, in: 0...10)
                    }
                }

                Section{
                    Button{
                        self.image = nil
                        self.normalKeyColor = Design.colors.normalKeyColor
                        self.specialKeyColor = Design.colors.specialKeyColor
                        self.selectFontRowValue = 4
                        self.theme = .default
                    } label: {
                        Text("リセットする")
                            .foregroundColor(.red)
                    }
                }

            }
            Group{
                if refresh{
                    KeyboardPreview()
                        .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                        .clipped()
                }else{
                    KeyboardPreview()
                        .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                        .clipped()
                }
            }
            .background(RectangleGetter(rect: $captureRect))

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
        .onChange(of: normalKeyColor){value in
            if let normalKeyColor = ColorTools.rgba(value, process: {r, g, b, opacity in
                return Color(red: r, green: g, blue: b, opacity: max(0.001, opacity))
            }){
                self.theme.normalKeyFillColor = .color(normalKeyColor)
            }
            if let pushedKeyColor = ColorTools.hsv(value, process: {h, s, v, opacity in
                let base = (floor(v-0.5) + 0.5)*2
                return Color(hue: h, saturation: s, brightness: v - base * 0.1, opacity: max(0.05, sqrt(opacity)))
            }){
                self.theme.pushedKeyFillColor = .color(pushedKeyColor)
            }
        }
        .onChange(of: specialKeyColor){value in
            if let specialKeyColor = ColorTools.rgba(value, process: {r, g, b, opacity in
                return Color(red: r, green: g, blue: b, opacity: max(0.005, opacity))
            }){
                self.theme.specialKeyFillColor = .color(specialKeyColor)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: Button{
            do{
                try self.save()
            }catch{
                debug(error)
            }
            presentationMode.wrappedValue.dismiss()
        }label: {
            Text("完了")
        })
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

    func save() throws {
        //テーマを保存する
        if let capturedImage = UIApplication.shared.windows[0].rootViewController?.view?.getImage(rect: self.captureRect), let pngImageData = capturedImage.pngData(){
            self.theme.id = try Store.shared.themeIndexManager.saveTheme(theme: self.theme, capturedImage: pngImageData)
        }
    }

    static func load(){

    }
}
