//
//  ResultView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

protocol ResultViewItemData{
    var text: String {get}
    var inputable: Bool {get}
}

private final class ResultModelVariableSection<Candidate: ResultViewItemData>: ObservableObject{
    @Published fileprivate var results: [ResultData<Candidate>] = []
    @Published fileprivate var scrollViewProxy: ScrollViewProxy? = nil
}

struct ResultData<Candidate: ResultViewItemData>: Identifiable{
    var id: Int
    var candidate: Candidate
}

struct ResultView<Candidate: ResultViewItemData>: View {
    private let model: ResultModel<Candidate>
    @ObservedObject private var modelVariableSection: ResultModelVariableSection<Candidate>
    @ObservedObject private var sharedResultData: SharedResultData<Candidate>
    @ObservedObject private var variableStates = VariableStates.shared

    @Binding private var isResultViewExpanded: Bool
    @Environment(\.themeEnvironment) private var theme

    init(model: ResultModel<Candidate>, isResultViewExpanded: Binding<Bool>, sharedResultData: SharedResultData<Candidate>){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.sharedResultData = sharedResultData
        self._isResultViewExpanded = isResultViewExpanded
    }

    var body: some View {
        Group{[unowned modelVariableSection] in
            if variableStates.showMoveCursorBar{
                MoveCursorBar()
            }else if variableStates.showTabBar, let tabBarData = try? CustardManager.load().tabbar(identifier: 0){
                TabBarView(data: tabBarData)
            }else{
                HStack{
                    ScrollView(.horizontal, showsIndicators: false){
                        ScrollViewReader{scrollViewProxy in
                            LazyHStack(spacing: 10) {
                                ForEach(modelVariableSection.results, id: \.id){(data: ResultData<Candidate>) in
                                    if data.candidate.inputable{
                                        Button{
                                            Sound.click()
                                            self.pressed(candidate: data.candidate)
                                        } label: {
                                            Text(data.candidate.text)
                                        }
                                        .buttonStyle(ResultButtonStyle(height: Design.shared.resultViewHeight*0.6, theme: theme))
                                        .contextMenu{
                                            ResultContextMenuView(text: data.candidate.text)
                                        }
                                        .id(data.id)
                                    }else{
                                        Text(data.candidate.text)
                                            .font(Design.fonts.resultViewFont(theme: theme))
                                            .underline(true, color: .accentColor)
                                    }
                                }
                            }.onAppear{
                                modelVariableSection.scrollViewProxy = scrollViewProxy
                            }
                        }
                        .padding(.horizontal, 5)
                    }

                    if modelVariableSection.results.count > 1{
                        //候補を展開するボタン
                        Button(action: {
                            self.expand()
                        }){
                            Image(systemName: "chevron.down")
                                .font(Design.fonts.iconImageFont(theme: theme))
                                .frame(height: 18)
                        }
                        .buttonStyle(ResultButtonStyle(height: Design.shared.resultViewHeight*0.6, theme: theme))
                        .padding(.trailing, 10)
                    }
                }.frame(height: Design.shared.resultViewHeight)
            }
        }
    }

    private func pressed(candidate: Candidate){
        variableStates.action.notifyComplete(candidate)
    }

    private func expand(){
        self.isResultViewExpanded = true
        self.sharedResultData.results = self.modelVariableSection.results
    }
}


struct ResultContextMenuView: View {
    private let text: String

    init(text: String){
        self.text = text
    }
    
    var body: some View {
        Group{
            Button(action: {
                VariableStates.shared.magnifyingText = text
                VariableStates.shared.isTextMagnifying = true
            }) {
                Text("大きな文字で表示する")
                Image(systemName: "plus.magnifyingglass")
            }
        }
    }
}

struct ResultModel<Candidate: ResultViewItemData>{
    fileprivate var variableSection = ResultModelVariableSection<Candidate>()

    func setResults(_ results: [Candidate]){
        self.variableSection.results = results.indices.map{ResultData(id: $0, candidate: results[$0])}
        self.scrollTop()
    }

    func scrollTop(){
        if let proxy = self.variableSection.scrollViewProxy{
            proxy.scrollTo(0, anchor: .trailing)
        }
    }
}

struct ResultButtonStyle: ButtonStyle {
    private let height: CGFloat
    private let theme: ThemeData

    init(height: CGFloat, theme: ThemeData){
        self.theme = theme
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.fonts.resultViewFont(theme: theme))
            .frame(height: height)
            .padding(.all, 5)
            .foregroundColor(theme.resultTextColor.color) //文字色は常に不透明度1で描画する
            .background(
                configuration.isPressed ?
                    theme.pushedKeyFillColor.color.opacity(0.5) :
                    theme.resultBackgroundColor.color
            )
            .cornerRadius(5.0)
    }
}

