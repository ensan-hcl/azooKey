//
//  ExpandedResultView.swift
//  Keyboard
//
//  Created by ensan on 2020/09/05.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI

struct ExpandedResultView<Candidate: ResultViewItemData>: View {
    @Binding private var isResultViewExpanded: Bool

    private var splitedResults: [SplitedResultData<Candidate>]
    private var buttonWidth: CGFloat {
        Design.resultViewHeight() * 0.5
    }
    private var buttonHeight: CGFloat {
        Design.resultViewHeight() * 0.6
    }

    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    init(isResultViewExpanded: Binding<Bool>, resultData: [ResultData<Candidate>]) {
        self._isResultViewExpanded = isResultViewExpanded
        self.splitedResults = Self.registerResults(results: resultData)
    }

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                    .frame(height: 18)
                // 候補をしまうボタン
                Button(action: {
                    self.collapse()
                }) {
                    ZStack {
                        Color(white: 1, opacity: 0.001)
                            .frame(width: buttonWidth)
                        Image(systemName: "chevron.up")
                            .font(Design.fonts.iconImageFont(theme: theme))
                            .frame(height: 18)
                    }
                }
                .buttonStyle(ResultButtonStyle(height: buttonHeight))
                .padding(.trailing, 10)
            }
            .padding(.top, 10)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(splitedResults, id: \.id) {results in
                        Divider()
                        HStack {
                            ForEach(results.results, id: \.id) {datum in
                                Button(action: {
                                    self.pressed(data: datum)
                                }) {
                                    Text(datum.candidate.text)
                                }
                                .buttonStyle(ResultButtonStyle(height: 18))
                                .contextMenu {
                                    ResultContextMenuView(candidate: datum.candidate)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 3)
                .padding(.leading, 15)
            }
        }
        .frame(height: VariableStates.shared.interfaceSize.height, alignment: .bottom)
    }

    private func pressed(data: ResultData<Candidate>) {
        self.action.notifyComplete(data.candidate)
        self.collapse()
    }

    private func collapse() {
        isResultViewExpanded = false
    }

    private static func registerResults(results: [ResultData<Candidate>]) -> [SplitedResultData<Candidate>] {
        var curSum: CGFloat = .zero
        var splited: [SplitedResultData<Candidate>] = []
        var curResult: [ResultData<Candidate>] = []
        let font = UIFont.systemFont(ofSize: Design.fonts.resultViewFontSize + 1)
        results.forEach {[unowned font] datum in
            let width = datum.candidate.text.size(withAttributes: [.font: font]).width + 20
            if (curSum + width) < VariableStates.shared.interfaceSize.width {
                curResult.append(datum)
                curSum += width
            } else {
                splited.append(SplitedResultData(id: splited.count, results: curResult))
                curSum = width
                curResult = [datum]
            }
        }
        splited.append(SplitedResultData(id: splited.count, results: curResult))
        return splited
    }

}

private struct SplitedResultData<Candidate: ResultViewItemData>: Identifiable {
    let id: Int
    let results: [ResultData<Candidate>]
}
