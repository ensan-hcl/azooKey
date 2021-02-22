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
            defer{
                DispatchQueue.main.async{
                    self.processState = .none
                }
            }
            DispatchQueue.main.async{
                self.processState = .processFile
            }
            guard let data = data else {
                DispatchQueue.main.async{
                    self.importedData = .failure(.invalidData)
                }
                return
            }
            
            guard let custard = try? JSONDecoder().decode(Custard.self, from: data) else {
                DispatchQueue.main.async{
                    self.importedData = .failure(.invalidFile)
                }
                return
            }
            DispatchQueue.main.async{
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

    var body: some View {
        Form{
            Section(header: Text("作る")){
                
            }
            Section(header: Text("読み込む")){
                Text("カスタムタブファイルをファイルから読み込む")
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
                } label: {
                    Text("カスタムタブファイルをURL読み込み")
                }

                switch data.importedData{
                case .none:
                    EmptyView()
                case let .success(custard):
                    Text("「\(custard.identifier)」の読み込みに成功しました")
                case let .failure(error):
                    Text(verbatim: "\(error)")
                }

                VStack{
                    Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                    FallbackLink("カスタムタブファイルの作り方", destination: "https://google.com")
                }
            }

        }
        .navigationBarTitle(Text("カスタムタブの管理"), displayMode: .inline)
    }
}
