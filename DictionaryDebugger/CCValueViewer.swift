//
//  CCValueViewer.swift
//  DictionaryDebugger
//
//  Created by ensan on 2023/05/27.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI
import SwiftUIUtils
import KanaKanjiConverterModule

struct CCValueViewer: View {
    private let dicdataStore: DicdataStore

    init (dicdataStore: DicdataStore) {
        self.dicdataStore = dicdataStore
    }

    @State private var lcid = 0
    @State private var rcid = 0

    private func getCCValue() -> PValue? {
        if lcid > 1318 || rcid > 1318 {
            return nil
        }
        return dicdataStore.getCCValue(lcid, rcid)
    }

    var body: some View {
        VStack {
            Text("CC Values")
                .font(.headline)
            IntegerTextField("lcid", text: $lcid.converted(forward: String.init, backward: {Int($0) ?? 0}), range: 0...1318)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .submitLabel(.done)
            IntegerTextField("rcid", text: $rcid.converted(forward: String.init, backward: {Int($0) ?? 0}), range: 0...1318)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .submitLabel(.done)
            Text(verbatim: """
            CC Value between \(lcid) and \(rcid): \(getCCValue()?.description ?? "Invalid value")
            """)
        }
    }
}
