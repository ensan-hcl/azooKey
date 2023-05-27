//
//  KanaKanjiConvertResultViewer.swift
//  DictionaryDebugger
//
//  Created by ensan on 2023/05/27.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI
import KanaKanjiConverterModule

struct KanaKanjiConvertResultViewer: View {
    private let converter: KanaKanjiConverter

    init (dicdataStore: DicdataStore) {
        self.converter = KanaKanjiConverter(dicdataStore: dicdataStore)
    }

    @State private var query = ""
    @State private var n_best = 10
    @State private var prefix = 10

    private func requestConversion() -> [Candidate] {
        var c = ComposingText()
        c.insertAtCursorPosition(query, inputStyle: .roman2kana)
        var options = ConvertRequestOptions.appDefault
        options.N_best = n_best
        let result = converter.requestCandidates(c, options: options)
        return result.mainResults
    }

    var body: some View {
        Text("KanaKanji Converter Viewer")
            .font(.headline)
        TextField("読みを入力", text: $query)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.search)
        IntegerTextField("n_best", text: $n_best.converted(forward: String.init, backward: {Int($0) ?? 10}), range: 1...1000)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .submitLabel(.done)
        IntegerTextField("n件表示", text: $prefix.converted(forward: String.init, backward: {Int($0) ?? 10}), range: 1...1000)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .submitLabel(.done)
        Text(requestConversion()
            .prefix(prefix)
            .map{"word: \($0.text), value: \($0.value), data: \($0.data.map{$0.debugDescription}.joined(separator: ", "))"}
            .joined(separator: "\n")
        )
    }
}
