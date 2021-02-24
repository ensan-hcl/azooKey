//
//  ManageCustardView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class ImportedCustardData: ObservableObject {
    enum ImportError: Error {
        case invalidURL
        case invalidData
        case invalidFile

        var description: LocalizedStringKey {
            switch self{
            case .invalidURL:
                return "URLが間違っている可能性があります"
            case .invalidData:
                return "データが取得できませんでした"
            case .invalidFile:
                return "正しくない形式のファイルです"
            }
        }
    }

    enum ProcessState: Error {
        case none
        case getURL
        case getFile
        case processFile

        var description: LocalizedStringKey? {
            switch self{
            case .none: return nil
            case .getFile: return "ファイルを取得中"
            case .getURL: return "URLを取得中"
            case .processFile: return "ファイルを処理中"
            }
        }
    }

    @Published var processState: ProcessState = .none

    @Published var downloadedData: Data? = nil
    @Published var failureData: ImportError? = nil

    var custard: Custard? = nil

    func reset(){
        self.processState = .none
        self.downloadedData = nil
        self.failureData = nil
    }

    func process(data: Data) -> Custard? {
        self.processState = .processFile
        guard let custard = try? JSONDecoder().decode(Custard.self, from: data) else {
            self.failureData = .invalidFile
            self.downloadedData = nil
            self.processState = .none
            return nil
        }
        self.processState = .none
        self.custard = custard
        return custard
    }

    func download(from urlString: String) {
        self.processState = .getURL
        print("ダウンロード開始")
        guard let url: URL = URL(string: urlString) else {
            DispatchQueue.main.async{
                self.failureData = .invalidURL
                self.processState = .none
            }
            return
        }
        self.processState = .getFile
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async{
                    self.failureData = .invalidData
                    self.processState = .none
                }
                return
            }
            DispatchQueue.main.async{
                print("ダウンロード終了")
                self.downloadedData = data
            }
        })

        task.resume()
    }
}

struct ManageCustardView: View {
    @ObservedObject private var data = ImportedCustardData()
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertType = AlertType.none
    @Binding private var manager: CustardManager
    @State private var showDocumentPicker = false
    @State var selectedDocument: Data = Data()
    @State var addTabBar = true
    init(manager: Binding<CustardManager>){
        self._manager = manager
    }

    enum AlertType{
        case none
        case overlapCustard(custard: Custard)
    }

    var body: some View {
        Form{
            Section(header: Text("一覧")){
                if manager.availableCustards.isEmpty{
                    Text("カスタムタブがまだありません")
                }else{
                    List{
                        ForEach(manager.availableCustards, id: \.self){identifier in
                            if let custard = try? manager.custard(identifier: identifier){
                                NavigationLink(destination: CustardInformationView(custard: custard, metadata: manager.metadata[identifier], manager: $manager)){
                                    Text(identifier)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }

            Section(header: Text("作る")){
                Text("登録したい文字を順番に書いていくだけでスクロール式のカスタムタブを作成することができます。")
                NavigationLink(destination: EditingScrollCustardView(manager: $manager)){
                    Text("作る")
                }

            }

            Section(header: Text("読み込む")){
                if let value = data.downloadedData,
                   let custard = (data.custard ?? data.process(data: value)){
                    Text("「\(custard.display_name)(\(custard.identifier))」の読み込みに成功しました")
                    CenterAlignedView{
                        KeyboardPreview(theme: .default, scale: 0.7, defaultTab: .custard(custard))
                    }
                    Button("保存"){
                        if manager.availableCustards.contains(custard.identifier){
                            self.showAlert = true
                            self.alertType = .overlapCustard(custard: custard)
                        }else{
                            self.saveCustard(custard: custard)
                        }
                    }
                    Toggle(isOn: $addTabBar){
                        Text("タブバーに追加")
                    }
                    Button("キャンセル"){
                        data.reset()
                    }
                }else{
                    if let text = data.processState.description{
                        ProgressView(text)
                    }
                    if let failure = data.failureData{
                        HStack{
                            Image(systemName: "exclamationmark.triangle")
                            Text(failure.description).foregroundColor(.red)
                        }
                    }
                    DisclosureGroup{

                        Button{
                            showDocumentPicker = true
                        } label: {
                            Text("読み込む")
                        }

                    } label: {
                        Text("iCloudから読み込む")
                    }

                    DisclosureGroup{
                        HStack{
                            TextField("URLを入力", text: $urlString)
                        }
                        Button{
                            data.download(from: urlString)
                        } label: {
                            Text("読み込む")
                        }
                    } label: {
                        Text("URLから読み込み")
                    }

                    Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                    FallbackLink("カスタムタブファイルの作り方", destination: "https://google.com")
                }
            }
        }
        .navigationBarTitle(Text("カスタムタブの管理"), displayMode: .inline)
        .alert(isPresented: $showAlert){
            switch alertType{
            case .none:
                return Alert(title: Text("アラート"))
            case let .overlapCustard(custard):
                return Alert(
                    title: Text("注意"),
                    message: Text("識別子\(custard.identifier)を持つカスタムタブが既に登録されています。上書きしますか？"),
                    primaryButton: .default(Text("上書き")){
                        self.saveCustard(custard: custard)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .sheet(isPresented: $showDocumentPicker){
            DocumentPicker(
                pickerResult: $data.downloadedData,
                isPresented: $showDocumentPicker,
                extensions: ["txt","custard","json"]
            )
        }
    }

    private func saveCustard(custard: Custard){
        do{
            try manager.saveCustard(custard: custard, metadata: .init(origin: .imported), updateTabBar: addTabBar)
            data.reset()
            urlString = ""
        } catch {
            debug(error)
        }
    }

    private func delete(at offsets: IndexSet) {
        let identifiers = offsets.map{manager.availableCustards[$0]}
        identifiers.forEach{
            manager.removeCustard(identifier: $0)
        }
    }

}
