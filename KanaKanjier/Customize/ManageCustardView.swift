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
            case .getFile: return "ファイルを取得中"
            case .getURL: return "URLを取得中"
            case .none: return nil
            case .processFile: return "ファイルを処理中"
            }
        }
    }

    @Published var importedData: Result<Custard, ImportError>? = nil
    @Published var processState: ProcessState = .none

    func download(from urlString: String){
        defer{
            processState = .none
        }
        self.processState = .getURL
        guard let url: URL = URL(string: urlString) else {
            self.importedData = .failure(.invalidURL)
            return
        }
        self.processState = .getFile
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            DispatchQueue.main.async{
                self.processState = .processFile
            }
            guard let data = data else {
                DispatchQueue.main.async{
                    self.processState = .none
                    self.importedData = .failure(.invalidData)
                }
                return
            }
            
            guard let custard = try? JSONDecoder().decode(Custard.self, from: data) else {
                DispatchQueue.main.async{
                    self.processState = .none
                    self.importedData = .failure(.invalidFile)
                }
                return
            }
            DispatchQueue.main.async{
                self.processState = .none
                self.importedData = .success(custard)
            }
            return
        })
        task.resume()
    }
}

struct ManageCustardView: View {
    @ObservedObject private var data = ImportedCustardData()
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertType = AlertType.none

    @State private var manager = VariableStates.shared.custardManager

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
                                NavigationLink(destination: CustardInformationView(custard: custard)){
                                    Text(identifier)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }

            Section(header: Text("作る")){
                
            }
            Section(header: Text("読み込む")){
                switch data.importedData{
                case .none, .failure:
                    DisclosureGroup{
                        if let text = data.processState.description{
                            ProgressView(text)
                        }else{
                            Button{
                                data.download(from: urlString)
                            } label: {
                                Text("読み込む")
                            }
                        }
                    } label: {
                        Text("iCloudから読み込む")
                    }

                    DisclosureGroup{
                        HStack{
                            TextField("URLを入力", text: $urlString)
                        }
                        if let text = data.processState.description{
                            ProgressView(text)
                        }else{
                            Button{
                                data.download(from: urlString)
                            } label: {
                                Text("読み込む")
                            }
                        }
                        if case let .failure(error) = data.importedData{
                            HStack{
                                Image(systemName: "exclamationmark.triangle")
                                Text(error.description)
                            }
                        }
                    } label: {
                        Text("URLから読み込み")
                    }

                    VStack{
                        Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                        FallbackLink("カスタムタブファイルの作り方", destination: "https://google.com")
                    }
                case let .success(custard):
                    Text("「\(custard.identifier)」の読み込みに成功しました")
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
                    Button("キャンセル"){
                        data.importedData = nil
                    }
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
    }

    private func saveCustard(custard: Custard){
        do{
            try manager.saveCustard(custard: custard)
            data.importedData = nil
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
