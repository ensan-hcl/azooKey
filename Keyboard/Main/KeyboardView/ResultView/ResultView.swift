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
    init(model: ResultModel){
        self.model = model
        self.modelVariableSection = model.variableSection
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
                                ForEach(modelVariableSection.results){data in
                                    if data.candidate.inputable{
                                        Button{
                                            SoundTools.click()
                                            self.model.pressed(candidate: data.candidate)
                                        } label: {
                                            Text(data.candidate.text)
                                        }
                                        .buttonStyle(ResultButtonStyle(height: Store.shared.design.resultViewHeight*0.6))
                                        .contextMenu{
                                            ResultContextMenuView(text: data.candidate.text)
                                        }
                                        .id(data.id)
                                    }else{
                                        Text(data.candidate.text)
                                            .font(Store.shared.design.fonts.resultViewFont)
                                            .underline(true, color: .accentColor)
                                    }
                                }
                            }.onAppear{
                                modelVariableSection.scrollViewProxy = scrollViewProxy
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .frame(height: Store.shared.design.resultViewHeight)
                    if modelVariableSection.results.count > 1{
                        //候補を展開するボタン
                        Button(action: {
                            self.model.expand()
                        }){
                            Image(systemName: "chevron.down")
                                .font(Store.shared.design.fonts.iconImageFont)
                                .frame(height: 18)
                        }
                        .buttonStyle(ResultButtonStyle(height: Store.shared.design.resultViewHeight*0.6))
                        .padding(.trailing, 10)
                    }
                }
            }
        }
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
        self.variableSection.scrollViewProxy?.scrollTo(0, anchor: .trailing)
    }

    func showMoveCursorView(_ bool: Bool){
        if self.variableSection.showMoveCursorView != bool{
            self.variableSection.showMoveCursorView = bool
        }
    }

    func toggleShowMoveCursorView(){
        self.variableSection.showMoveCursorView.toggle()
    }

    fileprivate func pressed(candidate: Candidate){
        Store.shared.action.registerComplete(candidate)
    }

    fileprivate func expand(){
        Store.shared.expandResult(results: self.variableSection.results)
    }

}

struct ResultButtonStyle: ButtonStyle {
    let height: CGFloat

    init(height: CGFloat){
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Store.shared.design.fonts.resultViewFont)
            .frame(height: height)
            .padding(.all, 5)
            .foregroundColor(.primary)
            .background(configuration.isPressed ? Color(UIColor.systemGray4):Store.shared.design.colors.backGroundColor)
            .cornerRadius(5.0)
    }
}

