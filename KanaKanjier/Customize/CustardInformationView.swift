//
//  CustardInformationView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate extension CustardLanguage {
    var label: LocalizedStringKey {
        switch self{

        case .english:
            return "英語"
        case .japanese:
            return "日本語"
        case .undefined:
            return "指定なし"
        }
    }
}

fileprivate extension CustardInputStyle {
    var label: LocalizedStringKey {
        switch self{
        case .direct:
            return "ローマ字かな入力"
        case .roman2kana:
            return "ダイレクト"
        }
    }
}

struct CustardInformationView: View {
    let custard: Custard
    var body: some View {
        Form{
            CenterAlignedView{
                KeyboardPreview(theme: .default, scale: 0.7, defaultTab: .custard(custard))
            }
            HStack{
                Text("識別子")
                Spacer()
                Text(custard.identifier).font(.system(.body, design: .monospaced))
            }
            HStack{
                Text("言語")
                Spacer()
                Text(custard.language.label)
            }
            HStack{
                Text("入力方式")
                Spacer()
                Text(custard.input_style.label)
            }
        }
        .navigationBarTitle(Text("カスタムタブの情報"), displayMode: .inline)
    }
}
