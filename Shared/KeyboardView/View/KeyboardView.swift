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

    private var sharedResultData = SharedResultData<Candidate>()

    init(resultModel: ResultModel<Candidate>){
        self.resultModel = resultModel
    }

    var body: some View {
        ZStack{
            VariableStates.shared.themeManager.theme.backgroundColor
                .frame(maxWidth: .infinity)
                .overlay(
                    Group{
                        if let image = VariableStates.shared.themeManager.theme.picture.image{
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: Design.shared.screenWidth, height: Design.shared.keyboardScreenHeight)
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
                        switch (variableStates.keyboardOrientation, variableStates.keyboardLayout){
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
                        switch (variableStates.keyboardOrientation, variableStates.keyboardLayout){
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
