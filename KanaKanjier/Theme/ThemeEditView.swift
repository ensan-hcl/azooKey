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
    private let base: ThemeData
    @State private var theme: ThemeData = .base
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var selectFontRowValue: Double = 4
    @Binding private var manager: ThemeIndexManager

    @State private var trimmedImage: UIImage? = nil
    @State private var isTrimmingViewPresented = false
    @State private var pickedImage: UIImage? = nil
    @State private var isSheetPresented = false
    @State private var viewType = ViewType.editor

    @ObservedObject private var storeVariableSection = Store.variableSection

    private enum ViewType{
        case editor
        case themeShareView
    }

    private let title: LocalizedStringKey

    @State private var normalKeyColor = ThemeData.base.normalKeyFillColor.color
    @State private var tab: Tab.ExistentialTab
    private var shareImage = ShareImage()

    init(index: Int?, manager: Binding<ThemeIndexManager>){
        let tab: Tab.ExistentialTab = {
            switch Store.variableSection.japaneseLayout{
            case .flick:
                return .flick_hira
            case .qwerty:
                return .qwerty_hira
            case let .custard(identifier):
                return .custard((try? CustardManager.load().custard(identifier: identifier)) ?? .errorMessage)
            }
        }()

        self._tab = State(initialValue: tab)
        self._manager = manager
        if let index = index{
            do{
                var theme = try manager.wrappedValue.theme(at: index)
                theme.id = index
                self._theme = State(initialValue: theme)
                self.base = theme
                self._normalKeyColor = State(initialValue: theme.normalKeyFillColor.color)
            } catch {
                debug(error)
                self.base = .base
            }
            self.title = "着せ替えを編集"
        }else{
            self.base = .base
            self.title = "着せ替えを作成"
        }
        self.theme.suggestKeyFillColor = .color(Color.init(white: 1))
    }
    // PHPickerの設定
    private var config: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    var body: some View {
        switch viewType{
        case .editor:
            VStack{
                Form{
                    Section(header: Text("背景")){
                        if let _ = trimmedImage{
                            Button{
                                self.isSheetPresented = true
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
                                self.isSheetPresented = true
                            } label: {
                                HStack{
                                    Text("\(systemImage: "photo")画像を選ぶ")
                                }
                            }
                            GenericColorPicker("背景の色", selection: $theme.backgroundColor, initialValue: base.backgroundColor.color){.color($0)}
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
                        GenericColorPicker("変換候補の文字の色", selection: $theme.resultTextColor, initialValue: base.resultTextColor.color){.color($0)}
                        GenericColorPicker("変換候補の背景色", selection: $theme.resultBackgroundColor, initialValue: base.resultBackgroundColor.color){.color($0)}
                    }

                    Section(header: Text("キー")){
                        GenericColorPicker("キーの文字の色", selection: $theme.textColor, initialValue: base.textColor.color){.color($0)}

                        ColorPicker("通常キーの背景色", selection: $normalKeyColor)
                        GenericColorPicker("特殊キーの背景色", selection: $theme.specialKeyFillColor, initialValue: base.specialKeyFillColor.color){value in
                            if let specialKeyColor = ColorTools.rgba(value, process: {r, g, b, opacity in
                                return Color(red: r, green: g, blue: b, opacity: max(0.005, opacity))
                            }){
                                return .color(specialKeyColor)
                            }
                            return .color(value)
                        }

                        GenericColorPicker("枠線の色", selection: $theme.borderColor, initialValue: base.borderColor.color){.color($0)}
                        HStack{
                            Text("枠線の太さ")
                            Slider(value: $theme.borderWidth, in: 0...10)
                        }
                    }

                    Section{
                        Button{
                            self.pickedImage = nil
                            self.trimmedImage = nil
                            self.normalKeyColor = self.base.normalKeyFillColor.color
                            self.selectFontRowValue = 4
                            self.theme = self.base
                        } label: {
                            Text("リセットする")
                                .foregroundColor(.red)
                        }
                    }

                }
                KeyboardPreview(theme: self.theme, defaultTab: tab)
                NavigationLink(destination: Group{
                    if let image = pickedImage{
                        TrimmingView(
                            uiImage: image,
                            resultImage: $trimmedImage,
                            maxSize: CGSize(width: 1280, height: 720),
                            aspectRatio: CGSize(width: SemiStaticStates.shared.screenWidth, height: Design.shared.keyboardScreenHeight)
                        )}
                }, isActive: $isTrimmingViewPresented){
                    EmptyView()
                }

            }
            .background(Color(.secondarySystemBackground))
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
                    self.theme.backgroundColor = .color(Color.white.opacity(0))
                    self.theme.resultBackgroundColor = .color(Color.white.opacity(0))
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
            .sheet(isPresented: $isSheetPresented){
                PhotoPicker(configuration: self.config,
                            pickerResult: $pickedImage,
                            isPresented: $isSheetPresented)
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
                    //presentationMode.wrappedValue.dismiss()
                    self.viewType = .themeShareView
                }label: {
                    Text("完了")
                })
            .onChange(of: storeVariableSection.japaneseLayout){value in
                SettingData.shared.reload() //設定をリロードする
                self.tab = {
                    switch value{
                    case .flick:
                        return .flick_hira
                    case .qwerty:
                        return .qwerty_hira
                    case let .custard(identifier):
                        return .custard((try? CustardManager.load().custard(identifier: identifier)) ?? .errorMessage)
                    }
                }()
            }
        case .themeShareView:
            ThemeShareView(theme: self.theme, shareImage: shareImage){
                presentationMode.wrappedValue.dismiss()
            }
            .navigationBarTitle(Text("完了"), displayMode: .inline)
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
        }
    }

    private func save() throws {
        //テーマを保存する
        let id = try manager.saveTheme(theme: self.theme)
        self.theme.id = id
        manager.select(at: id)
    }
}
