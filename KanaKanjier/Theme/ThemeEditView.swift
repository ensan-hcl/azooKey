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
    @Binding private var manager: ThemeIndexManager

    @State private var isTrimmingViewPresented = false
    @State private var trimmedImage: UIImage? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var isPhotoPickerPresented = false

    let title: String

    init(index: Int?, manager: Binding<ThemeIndexManager>){
        self._manager = manager
        if let index = index{
            do{
                var theme = try manager.wrappedValue.theme(at: index)
                theme.id = index
                self._theme = State(initialValue: theme)
            } catch {
                print(error)
            }
            self.title = "着せ替えを編集"
        }else{
            self.title = "着せ替えを作成"
        }
        self.theme.suggestKeyFillColor = .color(Color.init(white: 1))
        VariableStates.shared.keyboardLayout = SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout)
    }

    @State private var normalKeyColor = Design.colors.normalKeyColor
    @State private var specialKeyColor = Design.colors.specialKeyColor
    @State private var backGroundColor = Design.colors.backGroundColor
    @State private var borderColor = Color(.displayP3, white: 1, opacity: 0)
    @State private var keyLabelColor = Color.primary
    @State private var resultTextColor = Color.primary

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
                    if let _ = trimmedImage{
                        Button{
                            self.isPhotoPickerPresented = true
                        } label: {
                            HStack{
                                Text("\(systemImage: "photo")画像を選び直す")
                            }
                        }
                        Button{
                            pickedImage = nil
                            trimmedImage = nil
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
                        ColorPicker("背景の色", selection: $backGroundColor)
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
                    ColorPicker("変換候補の文字の色", selection: $resultTextColor)
                }

                Section(header: Text("キー")){
                    ColorPicker("キーの文字の色", selection: $keyLabelColor)

                    ColorPicker("通常キーの背景色", selection: $normalKeyColor)
                    ColorPicker("特殊キーの背景色", selection: $specialKeyColor)

                    ColorPicker("枠線の色", selection: $borderColor)
                    HStack{
                        Text("枠線の太さ")
                        Slider(value: $theme.borderWidth, in: 0...10)
                    }
                }

                Section{
                    Button{
                        self.pickedImage = nil
                        self.trimmedImage = nil
                        self.normalKeyColor = Design.colors.normalKeyColor
                        self.specialKeyColor = Design.colors.specialKeyColor
                        self.backGroundColor = Design.colors.backGroundColor
                        self.borderColor = Color(.displayP3, white: 1, opacity: 0)
                        self.keyLabelColor = .primary
                        self.resultTextColor = .primary
                        self.selectFontRowValue = 4
                        self.theme = .default
                    } label: {
                        Text("リセットする")
                            .foregroundColor(.red)
                    }
                }

            }
            KeyboardPreview(theme: self.theme)
                .background(RectangleGetter(rect: $captureRect))
            NavigationLink(destination: Group{
                if let image = pickedImage{
                TrimmingView(
                    uiImage: image,
                    resultImage: $trimmedImage,
                    maxSize: CGSize(width: 1280, height: 720),
                    aspectRatio: CGSize(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                )}
            }, isActive: $isTrimmingViewPresented){
                EmptyView()
            }

        }
        .background(viewBackgroundColor)
        .onChange(of: pickedImage){value in
            if let _ = value{
                self.isTrimmingViewPresented = true
            }else{
                self.theme.picture = .none
            }
        }
        .onChange(of: trimmedImage){value in
            if let value = value{
                self.theme.picture = .uiImage(value)
                backGroundColor = Color.white.opacity(0)
                self.theme.backgroundColor = .color(Color.white.opacity(0))
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
        .onChange(of: backGroundColor){value in
            self.theme.backgroundColor = .color(value)
        }
        .onChange(of: borderColor){value in
            self.theme.borderColor = .color(value)
        }
        .onChange(of: keyLabelColor){value in
            self.theme.textColor = .color(value)
        }
        .onChange(of: resultTextColor){value in
            self.theme.resultTextColor = .color(value)
        }
        .sheet(isPresented: $isPhotoPickerPresented){
            PhotoPicker(configuration: self.config,
                        pickerResult: $pickedImage,
                        isPresented: $isPhotoPickerPresented)
        }
        .navigationBarTitle(Text(self.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button{
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("キャンセル")
            },
            trailing: Button{
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

    var viewBackgroundColor: Color {
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
            self.theme.id = try manager.saveTheme(theme: self.theme, capturedImage: pngImageData)
        }
    }
}
