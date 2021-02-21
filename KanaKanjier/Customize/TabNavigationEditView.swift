//
//  TabNavigationEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private struct EditingTabNavigationItem{
    var label: TabNavigationViewItemLabelType
    var disclosed: Bool
}

struct TabNavigationEditView: View {
    @State private var items: [EditingTabNavigationItem] = [
        EditingTabNavigationItem(label: .text("あいう"), disclosed: false),
        EditingTabNavigationItem(label: .text("ABC"), disclosed: true),
        EditingTabNavigationItem(label: .text("①②③"), disclosed: true)

    ]

    var body: some View {
        Form {
            List{
                ForEach(items.indices, id: \.self){i in
                    DisclosureGroup{
                        HStack{
                            Text("表示")
                            Spacer()
                            TabNavigationViewItemLabelEditView("ラベルを設定", label: $items[i].label)
                        }
                        Text("押した時の動作")
                    } label :{
                        switch items[i].label{
                        case let .text(text):
                            Text(text)
                        case let .imageAndText(image, text):
                            HStack{
                                Image(systemName: image)
                                Text(text)
                            }
                        case let .image(image):
                            Image(systemName: image)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("タブ移動ビューの編集"), displayMode: .inline)
    }
}

struct TabNavigationViewItemLabelEditView: View {
    internal init(_ placeHolder: LocalizedStringKey, label: Binding<TabNavigationViewItemLabelType>) {
        self.placeHolder = placeHolder
        self._label = label
        switch label.wrappedValue{
        case let .text(text):
            self._labelText = State(initialValue: text)
        case let .image(systemName: image):
            break
        case let .imageAndText(systemName: image, text):
            break
        }
    }

    @Binding private var label: TabNavigationViewItemLabelType
    @State private var labelText = ""

    private let placeHolder: LocalizedStringKey

    var body: some View {
        TextField(placeHolder, text: $labelText){ _ in } onCommit: {
            label = .text(labelText)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
