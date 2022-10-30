//
//  TabNavigationView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    private let data: TabBarData

    init(data: TabBarData) {
        self.data = data
    }

    var body: some View {
        Group {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(data.items.indices, id: \.self) {i in
                        let item = data.items[i]
                        Button {
                            VariableStates.shared.action.registerActions(item.actions.map {$0.actionType})
                        } label: {
                            switch item.label {
                            case let .text(text):
                                Text(text)
                            case let .imageAndText(value):
                                HStack {
                                    Image(systemName: value.systemName)
                                    Text(value.text)
                                }
                            case let .image(image):
                                Image(systemName: image)
                            }
                        }
                        .buttonStyle(ResultButtonStyle(height: Design.resultViewHeight() * 0.6))
                    }
                }
            }
        }.frame(height: Design.resultViewHeight())
    }
}
