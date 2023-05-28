//
//  MMValueViewer.swift
//  DictionaryDebugger
//
//  Created by ensan on 2023/05/27.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI
import SwiftUIUtils
import KanaKanjiConverterModule

struct MMValueViewer: View {
    private let dicdataStore: DicdataStore

    init (dicdataStore: DicdataStore) {
        self.dicdataStore = dicdataStore
    }

    @State private var lmid = 0
    @State private var rmid = 0

    private func getMMValue() -> PValue? {
        if lmid > 502 || rmid > 502 {
            return nil
        }
        return dicdataStore.getMMValue(lmid, rmid)
    }

    var body: some View {
        VStack {
            Text("MM Values")
                .font(.headline)
            IntegerTextField("lmid", text: $lmid.converted(forward: String.init, backward: {Int($0) ?? 0}), range: 0...1318)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .submitLabel(.done)
            IntegerTextField("rmid", text: $rmid.converted(forward: String.init, backward: {Int($0) ?? 0}), range: 0...1318)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .submitLabel(.done)
            Text(verbatim: """
            MM Value between \(lmid) and \(rmid): \(getMMValue()?.description ?? "Invalid value")
            """)
        }
    }
}
