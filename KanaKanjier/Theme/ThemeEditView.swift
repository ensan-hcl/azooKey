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

private struct ThemeColorTranslator: Intertranslator {
    typealias First = ThemeColor
    typealias Second = Color

    static func convert(_ first: ThemeColor) -> Color {
        first.color
    }

    static func convert(_ second: Color) -> ThemeColor {
        .color(second)
    }
}

private struct ThemeSpecialKeyColorTranslator: Intertranslator {
    typealias First = ThemeColor
    typealias Second = Color

    static func convert(_ first: ThemeColor) -> Color {
        ThemeColorTranslator.convert(first)
    }

    static func convert(_ second: Color) -> ThemeColor {
        if let keyColor = ColorTools.rgba(second, process: {r, g, b, opacity in
            return Color(.displayP3, red: r, green: g, blue: b, opacity: max(0.001, opacity))
        }) {
            return .color(keyColor)
        }
        return .color(second)
    }
}

private struct ThemeNormalKeyColorTranslator: Intertranslator {
    typealias First = ThemeColor
    typealias Second = Color

    static func convert(_ first: ThemeColor) -> Color {
        ThemeColorTranslator.convert(first)
    }

    static func convert(_ second: Color) -> ThemeColor {
        if let keyColor = ColorTools.rgba(second, process: {r, g, b, opacity in
            return Color(.displayP3, red: r, green: g, blue: b, opacity: max(0.001, opacity))
        }) {
            return .color(keyColor)
        }
        return .color(second)
    }
}

private struct ThemeFontDoubleTranslator: Intertranslator {
    typealias First = ThemeFontWeight
    typealias Second = Double

    static func convert(_ first: First) -> Second {
        return Double(first.rawValue)
    }

    static func convert(_ second: Second) -> First {
        return ThemeFontWeight.init(rawValue: Int(second)) ?? .regular
    }
}

struct ThemeEditView: View {
    private let base: ThemeData
    @State private var theme: ThemeData = .base
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding private var manager: ThemeIndexManager

    @State private var trimmedImage: UIImage?
    @State private var isTrimmingViewPresented = false
    @State private var pickedImage: UIImage?
    @State private var isSheetPresented = false
    @State private var viewType = ViewType.editor

    @ObservedObject private var storeVariableSection = Store.variableSection

    @BindingTranslate<ThemeData, ThemeColorTranslator> private var backgroundColor = \.backgroundColor
    @BindingTranslate<ThemeData, ThemeColorTranslator> private var resultBackgroundColor = \.resultBackgroundColor
    @BindingTranslate<ThemeData, ThemeColorTranslator> private var resultTextColor = \.resultTextColor
    @BindingTranslate<ThemeData, ThemeColorTranslator> private var textColor = \.textColor
    @BindingTranslate<ThemeData, ThemeColorTranslator> private var borderColor = \.borderColor

    @BindingTranslate<ThemeData, ThemeNormalKeyColorTranslator> private var normalKeyFillColor = \.normalKeyFillColor
    @BindingTranslate<ThemeData, ThemeSpecialKeyColorTranslator> private var specialKeyFillColor = \.specialKeyFillColor

    @BindingTranslate<ThemeData, ThemeFontDoubleTranslator> private var textFont = \.textFont

    private enum ViewType {
        case editor
        case themeShareView
    }

    private let title: LocalizedStringKey

    @State private var tab: Tab.ExistentialTab
    private var shareImage = ShareImage()

    init(index: Int?, manager: Binding<ThemeIndexManager>) {
        let tab: Tab.ExistentialTab = {
            switch Store.variableSection.japaneseLayout {
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
        if let index = index {
            do {
                var theme = try manager.wrappedValue.theme(at: index)
                theme.id = index
                self._theme = State(initialValue: theme)
                self.base = theme
            } catch {
                debug(error)
                self.base = .base
            }
            self.title = "着せ替えを編集"
        } else {
            self.base = .base
            self.title = "着せ替えを作成"
        }
        self.theme.suggestKeyFillColor = .color(.init(white: 1))
    }
    // PHPickerの設定
    private var config: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    var body: some View {
        switch viewType {
        case .editor:
            VStack {
                Form {
                    Section(header: Text("背景")) {
                        if trimmedImage != nil {
                            Button {
                                self.isSheetPresented = true
                            } label: {
                                HStack {
                                    Text("\(systemImage: "photo")画像を選び直す")
                                }
                            }
                            Button {
                                pickedImage = nil
                                trimmedImage = nil
                            } label: {
                                HStack {
                                    Text("画像を削除")
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            Button {
                                self.isSheetPresented = true
                            } label: {
                                HStack {
                                    Text("\(systemImage: "photo")画像を選ぶ")
                                }
                            }
                            ColorPicker("背景の色", selection: $theme.translated($backgroundColor))
                        }
                    }
                    Section(header: Text("文字")) {
                        HStack {
                            Text("文字の太さ")
                            Slider(value: $theme.translated($textFont), in: 1...9.9)
                        }
                    }

                    Section(header: Text("変換候補")) {
                        ColorPicker("変換候補の文字の色", selection: $theme.translated($resultTextColor))
                        ColorPicker("変換候補の背景色", selection: $theme.translated($resultBackgroundColor))
                    }

                    Section(header: Text("キー")) {
                        ColorPicker("キーの文字の色", selection: $theme.translated($textColor))
                        ColorPicker("通常キーの背景色", selection: $theme.translated($normalKeyFillColor))
                        ColorPicker("特殊キーの背景色", selection: $theme.translated($specialKeyFillColor))
                        ColorPicker("枠線の色", selection: $theme.translated($borderColor))
                        HStack {
                            Text("枠線の太さ")
                            Slider(value: $theme.borderWidth, in: 0...10)
                        }
                    }

                    Section {
                        Button {
                            self.pickedImage = nil
                            self.trimmedImage = nil
                            self.theme = self.base
                        } label: {
                            Text("リセットする")
                                .foregroundColor(.red)
                        }
                    }

                }
                KeyboardPreview(theme: self.theme, defaultTab: tab)
                NavigationLink(destination: Group {
                    if let image = pickedImage {
                        TrimmingView(
                            uiImage: image,
                            resultImage: $trimmedImage,
                            maxSize: CGSize(width: 1280, height: 720),
                            aspectRatio: CGSize(width: SemiStaticStates.shared.screenWidth, height: Design.shared.keyboardScreenHeight)
                        )}
                }, isActive: $isTrimmingViewPresented) {
                    EmptyView()
                }

            }
            .background(Color(.secondarySystemBackground))
            .onChange(of: pickedImage) {value in
                if value != nil {
                    self.isTrimmingViewPresented = true
                } else {
                    self.theme.picture = .none
                }
            }
            .onChange(of: trimmedImage) {value in
                if let value = value {
                    self.theme.picture = .uiImage(value)
                    self.theme.backgroundColor = .color(.white.opacity(0))
                    self.theme.resultBackgroundColor = .color(.white.opacity(0))
                } else {
                    self.theme.picture = .none
                }
            }
            .onChange(of: theme.normalKeyFillColor) {value in
                if let pushedKeyColor = ColorTools.hsv(value.color, process: {h, s, v, opacity in
                    let base = (floor(v - 0.5) + 0.5) * 2
                    return Color(hue: h, saturation: s, brightness: v - base * 0.1, opacity: max(0.05, sqrt(opacity)))
                }) {
                    self.theme.pushedKeyFillColor = .color(pushedKeyColor)
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                PhotoPicker(configuration: self.config,
                            pickerResult: $pickedImage,
                            isPresented: $isSheetPresented)
            }
            .navigationBarTitle(Text(self.title), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("キャンセル")
                },
                trailing: Button {
                    do {
                        try self.save()
                    } catch {
                        debug(error)
                    }
                    // presentationMode.wrappedValue.dismiss()
                    self.viewType = .themeShareView
                }label: {
                    Text("完了")
                })
            .onChange(of: storeVariableSection.japaneseLayout) {value in
                SettingData.shared.reload() // 設定をリロードする
                self.tab = {
                    switch value {
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
            ThemeShareView(theme: self.theme, shareImage: shareImage) {
                presentationMode.wrappedValue.dismiss()
                Store.shared.shouldTryRequestReview = true
            }
            .navigationBarTitle(Text("完了"), displayMode: .inline)
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
        }
    }

    private func save() throws {
        // テーマを保存する
        let id = try manager.saveTheme(theme: self.theme)
        self.theme.id = id
        manager.select(at: id)
    }
}
