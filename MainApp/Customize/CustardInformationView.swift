//
//  CustardInformationView.swift
//  MainApp
//
//  Created by ensan on 2021/02/23.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

fileprivate extension CustardLanguage {
    var label: LocalizedStringKey {
        switch self {
        case .en_US:
            return "英語"
        case .ja_JP:
            return "日本語"
        case .el_GR:
            return "ギリシャ語"
        case .undefined:
            return "指定なし"
        case .none:
            return "変換なし"
        }
    }
}

fileprivate extension CustardInputStyle {
    var label: LocalizedStringKey {
        switch self {
        case .direct:
            return "ダイレクト"
        case .roman2kana:
            return "ローマ字かな入力"
        }
    }
}

fileprivate extension CustardInternalMetaData.Origin {
    var description: LocalizedStringKey {
        switch self {
        case .userMade:
            return "このアプリで作成"
        case .imported:
            return "読み込んだデータ"
        }
    }
}

private struct ExportedCustardData {
    let data: Data
    let fileIdentifier: String
}

fileprivate final class ShareURL {
    private(set) var url: URL?

    func setURL(_ url: URL?) {
        if let url {
            self.url = url
        }
    }
}

struct CustardInformationView: View {
    private let initialCustard: Custard
    @Binding private var manager: CustardManager
    @State private var showActivityView = false
    @State private var exportedData = ShareURL()
    @State private var added = false
    init(custard: Custard, manager: Binding<CustardManager>) {
        self.initialCustard = custard
        self._manager = manager
    }

    private var custard: Custard {
        (try? manager.custard(identifier: initialCustard.identifier)) ?? initialCustard
    }

    var body: some View {
        Form {
            CenterAlignedView {
                KeyboardPreview(scale: 0.7, defaultTab: .custard(custard))
            }
            HStack {
                Text("タブ名")
                Spacer()
                Text(custard.metadata.display_name)
            }
            HStack {
                Text("識別子")
                Spacer()
                Text(custard.identifier).font(.system(.body, design: .monospaced))
            }
            HStack {
                Text("変換")
                Spacer()
                Text(custard.language.label)
            }
            HStack {
                Text("入力方式")
                Spacer()
                Text(custard.input_style.label)
            }
            if let metadata = manager.metadata[custard.identifier] {
                HStack {
                    Text("由来")
                    Spacer()
                    Text(metadata.origin.description)
                }
                if metadata.origin == .userMade,
                   let userdata = try? manager.userMadeCustardData(identifier: custard.identifier) {
                    switch userdata {
                    case let .gridScroll(value):
                        NavigationLink("編集する", destination: EditingScrollCustardView(manager: $manager, editingItem: value))
                            .foregroundColor(.accentColor)
                    case let .tenkey(value):
                        NavigationLink("編集する", destination: EditingTenkeyCustardView(manager: $manager, editingItem: value))
                            .foregroundColor(.accentColor)
                    }
                }
            }

            if added || manager.checkTabExistInTabBar(tab: .custom(custard.identifier)) {
                Text("タブバーに追加済み")
            } else {
                Button("タブバーに追加") {
                    do {
                        try manager.addTabBar(item: TabBarItem(label: .text(custard.metadata.display_name), actions: [.moveTab(.custom(custard.identifier))]))
                        added = true
                    } catch {
                        debug(error)
                    }
                }
            }
            Button("共有する") {
                guard let encoded = try? JSONEncoder().encode(custard) else {
                    debug("書き出しに失敗")
                    return
                }
                // tmpディレクトリを取得
                let directory = FileManager.default.temporaryDirectory
                let path = directory.appendingPathComponent("\(custard.identifier).json")
                do {
                    // 書き出してpathをセット
                    try encoded.write(to: path, options: .atomicWrite)
                    exportedData.setURL(path)
                    showActivityView = true
                } catch {
                    debug(error.localizedDescription)
                    return
                }
            }
        }
        .navigationBarTitle(Text("カスタムタブの情報"), displayMode: .inline)
        .sheet(isPresented: self.$showActivityView, content: {
            ActivityView(
                activityItems: [exportedData.url].compactMap {$0},
                applicationActivities: nil
            )
        })
    }
}
