//
//  KeyboardView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

//キーボードの状態管理
enum TabState: Equatable{
    case hira
    case abc
    case number
    case other(String)

    static func ==(lhs: TabState, rhs: TabState) -> Bool {
        switch (lhs, rhs) {
        case (.hira, .hira), (.abc, .abc), (.number, .number): return true
        case let (.other(ls), .other(rs)): return ls == rs
        default:
            return false
        }
    }
}

struct KeyboardView: View {
    @ObservedObject private var variableStates = VariableStates.shared
    private let resultModel: ResultModel

    @State private var messageManager: MessageManager = MessageManager()
    @State private var isResultViewExpanded = false

    private var sharedResultData = SharedResultData()

    init(resultModel: ResultModel){
        self.resultModel = resultModel
    }

    var body: some View {
        ZStack{
            Design.shared.colors.backGroundColor
                .frame(maxWidth: .infinity)
                .overlay(
                    Group{
                        if let name = Design.shared.themeManager.theme.pictureFileName{
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: Design.shared.screenWidth)
                                .clipped()
                        }
                    }
                )
            if isResultViewExpanded{
                ExpandedResultView(isResultViewExpanded: $isResultViewExpanded, sharedResultData: sharedResultData)
                    .padding(.bottom, 2)
            }else{
                VStack(spacing: 0){
                    ResultView(model: resultModel, isResultViewExpanded: $isResultViewExpanded, sharedResultData: sharedResultData)
                        .padding(.vertical, 6)
                    if variableStates.refreshing{
                        switch (variableStates.keyboardOrientation, Design.shared.layout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView()
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView()
                        case (.horizontal, .flick):
                            HorizontalKeyboardView()
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView()
                        }
                    }else{
                        switch (variableStates.keyboardOrientation, Design.shared.layout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView()
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView()
                        case (.horizontal, .flick):
                            HorizontalKeyboardView()
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView()
                        }
                    }
                }.padding(.bottom, 2)
            }
            if variableStates.isTextMagnifying{
                LargeTextView()
            }
            
            ForEach(messageManager.necessaryMessages, id: \.id){data in
                if messageManager.requireShow(data.id){
                    MessageView(data: data, manager: $messageManager)
                }
            }
        }
    }
}
