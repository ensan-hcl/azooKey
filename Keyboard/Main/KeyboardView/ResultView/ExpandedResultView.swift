//
//  ExpandedResultView.swift
//  Keyboard
//
//  Created by β α on 2020/09/05.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct ExpandedResultView: View {
    private let model: ExpandedResultModel
    @ObservedObject private var modelVariableSection: ExpandedResultModelVariableSection

    init(model: ExpandedResultModel){
        self.model = model
        self.modelVariableSection = model.variableSection
    }

    // FIXME: これはGridViewが使えないからこうなっている。
    var body: some View {
        VStack{[unowned modelVariableSection] in
            HStack(alignment: .center){
                Spacer()
                    .frame(height: 18)
                //候補をしまうボタン
                Button(action: {
                    self.model.collapse()
                }){
                    Image(systemName: "chevron.up")
                        .font(Store.shared.design.fonts.iconImageFont)
                        .frame(height: 18)
                }
                .buttonStyle(ResultButtonStyle(height: 18))
                .padding(.trailing, 10)
            }
            .padding(.top, 10)
            .background(Store.shared.design.colors.backGroundColor)
            ScrollView{
                LazyVStack(alignment: .leading){
                    ForEach(modelVariableSection.splitedResults){results in
                        Divider()
                        HStack{
                            ForEach(results.results){datum in
                                Button(action: {
                                    self.model.pressed(data: datum)
                                }){
                                    Text(datum.candidate.text)
                                }
                                .buttonStyle(ResultButtonStyle(height: 18))
                                .contextMenu{
                                    ResultContextMenuView(text: datum.candidate.text)
                                }
                            }
                        }
                    }
                }
                .background(Store.shared.design.colors.backGroundColor)
                .padding(.vertical, 3)
                .padding(.leading, 15)

            }
        }
        .frame(height: Store.shared.design.keyboardHeight, alignment: .bottom)
    }
}


private final class ExpandedResultModelVariableSection: ObservableObject{
    @Published fileprivate var splitedResults: [SplitedResultData] = []
}

struct ExpandedResultModel{
    fileprivate var variableSection = ExpandedResultModelVariableSection()

    private func registerResults(results: [ResultData]){
        var curSum: CGFloat = .zero
        var splited: [SplitedResultData] = []
        var curResult: [ResultData] = []
        let font = UIFont.systemFont(ofSize: Store.shared.design.fonts.resultViewFontSize+1)
        results.forEach{[unowned font] datum in
            let width = datum.candidate.text.size(withAttributes: [.font: font]).width + 20
            if !Store.shared.design.isOverScreenWidth(curSum + width){
                curResult.append(datum)
                curSum += width
            }else{
                splited.append(SplitedResultData(id: splited.count, results: curResult))
                curSum = width
                curResult = [datum]
            }
        }
        splited.append(SplitedResultData(id: splited.count, results: curResult))
        self.variableSection.splitedResults = splited
    }

    fileprivate func pressed(data: ResultData){
        Store.shared.action.registerComplete(data.candidate)
        self.collapse()
    }

    func expand(results: [ResultData]){
        self.registerResults(results: results)
    }

    fileprivate func collapse(){
        Store.shared.collapseResult()
        self.variableSection.splitedResults = []
    }
}

struct SplitedResultData: Identifiable{
    let id: Int
    let results: [ResultData]
}
