//
//  TipsViewComponent.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct TipsContentView<Content: View>: View {
    private let content: () -> Content
    private let title: String

    init(_ title: String, @ViewBuilder _ content: @escaping () -> Content){
        self.content = content
        self.title = title
    }

    var body: some View {
        VStack{
            Form{
                self.content()
            }.navigationBarTitle(Text(self.title), displayMode: .inline)
        }
    }
}

struct TipsContentParagraph<Content: View>: View {
    private let content: () -> Content
    private let style: Font.TextStyle

    init(style: Font.TextStyle = .body, @ViewBuilder _ content: @escaping () -> Content){
        self.style = style
        self.content = content
    }

    var body: some View {
        Section{
            VStack(alignment: .leading, spacing: 10){
                self.content()
            }
            .font(.system(style))
            .multilineTextAlignment(.leading)
        }
    }
}


struct TipsImage: View {
    private let name: String

    init(_ name: String){
        self.name = name
    }
    
    var body: some View {
        Image(self.name)
            .resizable()
            .scaledToFit()
            .cornerRadius(2)
    }

}

