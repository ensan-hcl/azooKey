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
                        keyboardView(tab: variableStates.tabManager.currentTab)
                    }else{
                        keyboardView(tab: variableStates.tabManager.currentTab)
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

    func keyboardView(tab: Tab) -> some View {
        let actualTab: Tab
        if case let .user_dependent(type) = tab{
            actualTab = type.actualTab
        }else{
            actualTab = tab
        }

        return Group{
            switch actualTab{
            case .flick_hira:
                switch variableStates.keyboardOrientation{
                case .vertical:
                    VerticalFlickKeyboardView(keyModels: VerticalFlickDataProvider().hiraKeyboard , theme: theme)
                case .horizontal:
                    HorizontalFlickKeyboardView(keyModels: HorizontalFlickDataProvider().hiraKeyboard , theme: theme)
                }
            case .flick_abc:
                switch variableStates.keyboardOrientation{
                case .vertical:
                    VerticalFlickKeyboardView(keyModels: VerticalFlickDataProvider().abcKeyboard, theme: theme)
                case .horizontal:
                    HorizontalFlickKeyboardView(keyModels: HorizontalFlickDataProvider().abcKeyboard, theme: theme)
                }
            case .flick_numbersymbols:
                switch variableStates.keyboardOrientation{
                case .vertical:
                    VerticalFlickKeyboardView(keyModels: VerticalFlickDataProvider().numberKeyboard, theme: theme)
                case .horizontal:
                    HorizontalFlickKeyboardView(keyModels: HorizontalFlickDataProvider().numberKeyboard, theme: theme)
                }
            case .qwerty_hira:
                QwertyKeyboardView(keyModels: QwertyDataProvider().hiraKeyboard, theme: theme)
            case .qwerty_abc:
                QwertyKeyboardView(keyModels: QwertyDataProvider().abcKeyboard, theme: theme)
            case .qwerty_number:
                QwertyKeyboardView(keyModels: QwertyDataProvider().numberKeyboard, theme: theme)
            case .qwerty_symbols:
                QwertyKeyboardView(keyModels: QwertyDataProvider().symbolsKeyboard, theme: theme)
            case .user_dependent(_):
                EmptyView()
            case let .custard(custard):
                CustomKeyboardView(theme: theme, custard: custard)
            }
        }
    }
}
