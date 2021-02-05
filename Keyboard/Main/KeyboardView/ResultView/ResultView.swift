//
//  ResultView.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private final class ResultModelVariableSection: ObservableObject{
    @Published fileprivate var results: [ResultData] = []
    @Published fileprivate var showMoveCursorView = false
    @Published fileprivate var scrollViewProxy: ScrollViewProxy? = nil
}

struct ResultData: Identifiable{
    var id: Int
    var candidate: Candidate
}

struct ResultView: View{
    private let model: ResultModel
    @ObservedObject private var modelVariableSection: ResultModelVariableSection
    @ObservedObject private var sharedResultData: SharedResultData
    @Binding private var isResultViewExpanded: Bool

    init(model: ResultModel, isResultViewExpanded: Binding<Bool>, sharedResultData: SharedResultData){
        self.model = model
        self.modelVariableSection = model.variableSection
        self.sharedResultData = sharedResultData
        self._isResultViewExpanded = isResultViewExpanded
    }

    var body: some View {
        Group{[unowned modelVariableSection] in
            if modelVariableSection.showMoveCursorView{
                CursorMoveView()
            }else{
                HStack{
                    ScrollView(.horizontal, showsIndicators: false){
                        ScrollViewReader{scrollViewProxy in
                            LazyHStack(spacing: 10) {
                                ForEach(modelVariableSection.results, id: \.id){data in
                                    if data.candidate.inputable{
                                        Button{
                                            Sound.click()
                                            self.pressed(candidate: data.candidate)
                                        } label: {
                                            Text(data.candidate.text)
                                        }
                                        .buttonStyle(ResultButtonStyle(height: Design.shared.resultViewHeight*0.6))
                                        .contextMenu{
                                            ResultContextMenuView(text: data.candidate.text)
                                        }
                                        .id(data.id)
                                    }else{
                                        Text(data.candidate.text)
                                            .font(Design.shared.fonts.resultViewFont)
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
                                .font(Design.shared.fonts.iconImageFont)
                                .frame(height: 18)
                        }
                        .buttonStyle(ResultButtonStyle(height: Design.shared.resultViewHeight*0.6))
                        .padding(.trailing, 10)
                    }
                }.frame(height: Design.shared.resultViewHeight)
            }
        }
    }

    private func pressed(candidate: Candidate){
        Store.shared.action.notifyComplete(candidate)
    }

    private func expand(){
        self.isResultViewExpanded = true
        self.sharedResultData.results = self.modelVariableSection.results
    }

}


struct ResultContextMenuView: View {
    let text: String
    var body: some View {
        Group{
            Button(action: {
                Store.shared.keyboardModelVariableSection.magnifyingText = text
                Store.shared.keyboardModelVariableSection.isTextMagnifying = true
            }) {
                Text("大きな文字で表示する")
                Image(systemName: "plus.magnifyingglass")
            }
        }
    }
}

struct ResultModel{
    fileprivate var variableSection = ResultModelVariableSection()

    func setResults(_ results: [Candidate]){
        self.variableSection.results = results.indices.map{ResultData(id: $0, candidate: results[$0])}
        self.scrollTop()
    }

    func scrollTop(){
        if let proxy = self.variableSection.scrollViewProxy{
            proxy.scrollTo(0, anchor: .trailing)
        }else{
            debug("proxyが失われていて、先頭にスクロールできませんでした")
        }
    }

    func showMoveCursorView(_ bool: Bool){
        if self.variableSection.showMoveCursorView != bool{
            self.variableSection.showMoveCursorView = bool
        }
    }

    func toggleShowMoveCursorView(){
        self.variableSection.showMoveCursorView.toggle()
    }
}

struct ResultButtonStyle: ButtonStyle {
    let height: CGFloat

    init(height: CGFloat){
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Design.shared.fonts.resultViewFont)
            .frame(height: height)
            .padding(.all, 5)
            .foregroundColor(Design.shared.themeManager.theme.resultTextColor) //文字色は常に不透明度1で描画する
            .background(
                configuration.isPressed ?
                    Color(UIColor.systemGray4).opacity(Design.shared.themeManager.mainOpacity) :
                    Design.shared.colors.backGroundColor.opacity(Design.shared.themeManager.mainOpacity))
            .cornerRadius(5.0)
    }
}

