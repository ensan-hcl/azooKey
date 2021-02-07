//
//  ThemeEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/07.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ThemeEditView: View {
    @State private var theme: ThemeData = ThemeData.default
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectFontRowValue: Double = 4

    init(){
        VariableStates.shared.themeManager.theme = self.theme
    }

    @State private var refresh = false

    var body: some View {
        VStack{
            if refresh{
                KeyboardPreview()
                    .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardHeight)
                    .scaleEffect(0.9, anchor: .center)
            }else{
                KeyboardPreview()
                    .frame(width: Design.shared.keyboardWidth, height: Design.shared.keyboardHeight)
                    .scaleEffect(0.9, anchor: .center)
            }
            Form{
                Section(header: Text("文字")){
                    ColorPicker("キーの文字の色", selection: $theme.textColor)
                    ColorPicker("変換候補の文字の色", selection: $theme.resultTextColor)
                    HStack{
                        Text("文字の太さ")
                        Slider(value: $selectFontRowValue, in: 1...9.9){editing in
                            theme.textFont = ThemeFontWeight.init(rawValue: Int(selectFontRowValue)) ?? .regular
                        }
                    }
                }

                Section(header: Text("キーのデザイン")){
                    HStack{
                        Text("背景の透明度")
                        Slider(value: $theme.keyBackgroundColorOpacity, in: 0.001...1)
                    }
                    ColorPicker("枠線の色", selection: $theme.borderColor)
                }

            }
        }
        .background(backgroundColor)
        .onChange(of: theme){value in
            VariableStates.shared.themeManager.theme = self.theme
            self.refresh.toggle()
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
