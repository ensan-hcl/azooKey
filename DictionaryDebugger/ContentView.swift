//
//  ContentView.swift
//  DictionaryDebugger
//
//  Created by ensan on 2023/05/27.
//  Copyright © 2023 ensan. All rights reserved.
//

import KanaKanjiConverterModule
import SwiftUI

struct ContentView: View {
    @State private var dicdataStore: DicdataStore?

    var body: some View {
        ScrollView {
            if let dicdataStore {
                WordSearcher(dicdataStore: dicdataStore)
                Divider()
                CCValueViewer(dicdataStore: dicdataStore)
                Divider()
                MMValueViewer(dicdataStore: dicdataStore)
                Divider()
                KanaKanjiConvertResultViewer(dicdataStore: dicdataStore)
            } else {
                ProgressView("Dicdataを読み込んでいます")
            }
        }
        .textSelection(.enabled)
        .task {
            let task = Task {
                let dicdataStore = DicdataStore(convertRequestOptions: .appDefault)
                return dicdataStore
            }
            self.dicdataStore = await task.value
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
