//
//  LargeTextView.swift
//  Keyboard
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct LargeTextView: View {
    private let text: String
    init(_ text: String){
        self.text = text
    }
    
    private var font: Font {
        Font.system(size: Design.shared.getMaximumTextSize(self.text), weight: .regular, design: .serif)
    }
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: true, content: {
                Text(self.text)
                    .font(font)
            })
            Button(action: {
                Store.shared.keyboardModelVariableSection.isTextMagnifying = false
            }) {
                Image(systemName: "xmark")
                Text("閉じる")
                    .font(.body)
            }.frame(width: nil, height: Design.shared.keyViewSize.height)
        }
        .background(Color(UIColor.systemBackground))
        .frame(height: Design.shared.keyboardHeight + 2, alignment: .bottom)
    }
}
