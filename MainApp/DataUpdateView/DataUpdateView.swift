//
//  DataUpdateView.swift
//  KanaKanjier
//
//  Created by β α on 2021/01/29.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

struct DataUpdateView: View {

    private let id: MessageIdentifier
    @Binding private var manager: MessageManager
    private let process: () -> Void

    init(id: MessageIdentifier, manager: Binding<MessageManager>, process: @escaping () -> Void) {
        self.id = id
        self._manager = manager
        self.process = process
    }

    @State private var done = false

    var body: some View {
        ZStack {
            Color.white
            if done {
                VStack {
                    Text("\(systemImage: "checkmark.seal")完了しました")
                        .font(.title)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                manager.done(id)
                            }
                        }
                        .padding()
                    Button("閉じる") {
                        manager.done(id)
                    }
                    .padding()
                }
            } else {
                ProgressView("データの更新処理中です")
                    .onAppear {
                        let dispatchGroup = DispatchGroup()
                        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)

                        // 非同期処理を実行
                        dispatchGroup.enter()
                        dispatchQueue.async(group: dispatchGroup) {
                            process()
                        }
                        dispatchGroup.leave()

                        // 全ての非同期処理完了後にメインスレッドで処理
                        // 更新処理が短くても何が起こったかわかりやすいよう、1秒間余分に待つ
                        dispatchGroup.notify(queue: .main) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                done = true
                            }
                        }
                    }
            }
        }
    }
}
