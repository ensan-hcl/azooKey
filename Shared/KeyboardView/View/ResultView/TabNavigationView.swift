//
//  TabNavigationView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

enum TabNavigationViewItemLabelType{
    case text(String)
    case imageAndText(systemName: String, String)
    case image(systemName: String)
}

struct TabNavigationViewItem{
    let label: TabNavigationViewItemLabelType
    let actions: [ActionType]
}

struct TabNavigationView: View{
    private let theme: ThemeData
    @ObservedObject private var variableStates = VariableStates.shared

    let items: [TabNavigationViewItem] = [
        .init(label: .text("あいう"), actions: [.moveTab(.user_dependent(.japanese))]),
        .init(label: .text("ABC"), actions: [.moveTab(.user_dependent(.english))]),
        .init(label: .text("①②③"), actions: [.moveTab(.custard(.mock_qwerty_scroll))]),
    ]

    init(theme: ThemeData){
        self.theme = theme
    }

    var body: some View {
        Group{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(items.indices, id: \.self){i in
                        Button{
                            items[i].actions.forEach{variableStates.action.registerAction($0)}
                        } label: {
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
                        .buttonStyle(ResultButtonStyle(height: Design.shared.resultViewHeight*0.6, theme: theme))
                    }
                }
            }
        }.frame(height: Design.shared.resultViewHeight)
    }
}

