//
//  ShareWordView.swift
//  azooKey
//
//  Created by ensan on 2023/04/15.
//  Copyright © 2023 ensan. All rights reserved.
//

import AzooKeyUtils
import SwiftUI

struct ShareWordView: View {
    @State private var word = ""
    @State private var ruby = ""
    @State private var sending = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            if sending {
                Section {
                    HStack {
                        Text("申請中です")
                        ProgressView()
                    }
                }
            }
            Section(footer: Text("\(systemImage: "doc.on.clipboard")を長押しでペースト")) {
                HStack {
                    TextField("単語", text: $word)
                    Divider()
                    PasteLongPressButton($word)
                        .padding(.horizontal, 5)
                }
                HStack {
                    TextField("読み", text: $ruby)
                    Divider()
                    PasteLongPressButton($ruby)
                        .padding(.horizontal, 5)
                }
            }
            Section(footer: Text("この単語をazooKeyの本体辞書に追加することを申請します。\n個人情報を含む単語は申請しないでください。")) {
                Button("申請する") {
                    Task {
                        self.sending = true
                        _ = await SharedStore.sendSharedWord(word: word, ruby: ruby.toKatakana(), options: [])
                        self.sending = false
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
                .disabled(word.isEmpty && ruby.isEmpty)
            }
        }
        .multilineTextAlignment(.leading)
        .navigationBarTitle(Text("変換候補の追加申請"), displayMode: .inline)

    }
}
