//
//  WordSearcher.swift
//  DictionaryDebugger
//
//  Created by ensan on 2023/05/27.
//  Copyright © 2023 ensan. All rights reserved.
//

import KanaKanjiConverterModule
import SwiftUI

struct WordSearcher: View {
    private let dicdataStore: DicdataStore

    init (dicdataStore: DicdataStore) {
        self.dicdataStore = dicdataStore
    }

    @State private var query = ""

    private func searchWordForFullMatch() -> [DicdataElement] {
        var c = ComposingText()
        c.insertAtCursorPosition(query, inputStyle: .roman2kana)
        let result = dicdataStore.getLOUDSData(inputData: c, from: 0, to: c.input.endIndex - 1)
        return result.map(\.data)
    }

    var body: some View {
        Text("Word Searcher")
            .font(.headline)
        TextField("読みを入力", text: $query)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.search)
        Text(searchWordForFullMatch()
                .lazy
                .sorted {$0.value() > $1.value()}
                .map {"word: \($0.word), ruby: \($0.ruby), cid: \(($0.lcid, $0.rcid)), mid: \($0.mid), value: \($0.value()), adjust: \($0.adjust)"}
                .joined(separator: "\n")
        )
    }
}
