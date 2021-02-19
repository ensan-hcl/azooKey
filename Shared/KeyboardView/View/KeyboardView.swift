//
//  KeyboardView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/08.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyboardView<Candidate: ResultViewItemData>: View {
    @ObservedObject private var variableStates = VariableStates.shared
    private let resultModel: ResultModel<Candidate>

    @State private var messageManager: MessageManager = MessageManager()
    @State private var isResultViewExpanded = false

    private let theme: ThemeData

    private var sharedResultData = SharedResultData<Candidate>()

    init(theme: ThemeData, resultModel: ResultModel<Candidate>){
        self.theme = theme
        self.resultModel = resultModel
    }

    var body: some View {
        ZStack{
            theme.backgroundColor.color
                .frame(maxWidth: .infinity)
                .overlay(
                    Group{
                        if let image = theme.picture.image{
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: Design.shared.screenWidth, height: Design.shared.keyboardScreenHeight)
                                .clipped()
                        }
                    }
                )
            if isResultViewExpanded{
                ExpandedResultView(theme: theme, isResultViewExpanded: $isResultViewExpanded, sharedResultData: sharedResultData)
                    .padding(.bottom, 2)
            }else{
                VStack(spacing: 0){
                    ResultView(model: resultModel, theme: theme, isResultViewExpanded: $isResultViewExpanded, sharedResultData: sharedResultData)
                        .padding(.vertical, 6)
                    if variableStates.refreshing{
                        CustomKeyboardView(theme: theme)
                        /*
                        switch (variableStates.keyboardOrientation, variableStates.keyboardLayout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView(theme: theme)
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView(theme: theme)
                        case (.horizontal, .flick):
                            HorizontalKeyboardView(theme: theme)
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView(theme: theme)
                        }
 */
                    }else{
                        CustomKeyboardView(theme: theme)
                        /*
                        switch (variableStates.keyboardOrientation, variableStates.keyboardLayout){
                        case (.vertical, .flick):
                            VerticalFlickKeyboardView(theme: theme)
                        case (.vertical, .qwerty):
                            VerticalQwertyKeyboardView(theme: theme)
                        case (.horizontal, .flick):
                            HorizontalKeyboardView(theme: theme)
                        case (.horizontal, .qwerty):
                            HorizontalQwertyKeyboardView(theme: theme)
                        }
 */
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
