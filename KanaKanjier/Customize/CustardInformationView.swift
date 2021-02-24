//
//  CustardInformationView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/23.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate extension CustardLanguage {
    var label: LocalizedStringKey {
        switch self{

        case .english:
            return "英語"
        case .japanese:
            return "日本語"
        case .undefined:
            return "指定なし"
        }
    }
}

fileprivate extension CustardInputStyle {
    var label: LocalizedStringKey {
        switch self{
        case .direct:
            return "ダイレクト"
        case .roman2kana:
            return "ローマ字かな入力"
        }
    }
}

fileprivate extension CustardMetaData.Origin {
    var description: LocalizedStringKey {
        switch self{
        case .userMade:
            return "このアプリで作成"
        case .imported:
            return "読み込んだデータ"
        }
    }
}

fileprivate struct ExportedCustardData{
    let data: Data
    let fileIdentifier: String
}

fileprivate final class ShareURL{
    private(set) var url: URL?

    func setURL(_ url: URL?){
        if let url = url{
            self.url = url
        }
    }
}

struct CustardInformationView: View {
    let initialCustard: Custard
    let metadata: CustardMetaData?
    @Binding private var manager: CustardManager
    @State private var showActivityView = false
    @State private var exportedData = ShareURL()

    internal init(custard: Custard, metadata: CustardMetaData?, manager: Binding<CustardManager>) {
        self.initialCustard = custard
        self.metadata = metadata
        self._manager = manager
    }

    var custard: Custard {
        return (try? manager.custard(identifier: initialCustard.identifier)) ?? initialCustard
    }

    var body: some View {
        Form{
            CenterAlignedView{
                KeyboardPreview(theme: .default, scale: 0.7, defaultTab: .custard(custard))
            }
            HStack{
                Text("タブ名")
                Spacer()
                Text(custard.display_name)
            }
            HStack{
                Text("識別子")
                Spacer()
                Text(custard.identifier).font(.system(.body, design: .monospaced))
            }
            HStack{
                Text("言語")
                Spacer()
                Text(custard.language.label)
            }
            HStack{
                Text("入力方式")
                Spacer()
                Text(custard.input_style.label)
            }
            if let metadata = metadata {
                HStack{
                    Text("由来")
                    Spacer()
                    Text(metadata.origin.description)
                }
                if metadata.origin == .userMade,
                   let userdata = try? manager.userMadeCustardData(identifier: custard.identifier),
                   case let .gridScroll(value) = userdata{
                    NavigationLink(destination: EditingScrollCustardView(manager: $manager, editingItem: value)){
                        Text("編集する")
                    }
                }
            }
            Button("書き出す"){
                guard let encoded = try? JSONEncoder().encode(custard) else {
                    debug("書き出しに失敗")
                    return
                }
                //tmpディレクトリを取得
                let directory = FileManager.default.temporaryDirectory
                let path = directory.appendingPathComponent("\(custard.identifier).custard")
                do {
                    //書き出してpathをセット
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
        .sheet(isPresented: self.$showActivityView) {
            ActivityView(
                activityItems: [exportedData.url].compactMap{$0},
                applicationActivities: nil
            )
        }
    }
}
