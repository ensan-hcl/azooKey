//
//  ManageCustardView.swift
//  MainApp
//
//  Created by ensan on 2021/02/22.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI
import SwiftUIUtils
import SwiftUtils
import UniformTypeIdentifiers

private enum AlertType {
    case none
    case overlapCustard(custard: Custard)
}

private final class ImportedCustardData: ObservableObject {
    enum ImportError: Error {
        case invalidURL
        case invalidData
        case invalidFile

        var description: LocalizedStringKey {
            switch self {
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
            switch self {
            case .none: return nil
            case .getFile: return "ファイルを取得中"
            case .getURL: return "URLを取得中"
            case .processFile: return "ファイルを処理中"
            }
        }
    }

    @Published var processState: ProcessState = .none
    @Published var failureData: ImportError?
    @Published var custards: [Custard]?

    private var downloadedData: Data? {
        didSet {
            if let downloadedData {
                self.custards = self.process(data: downloadedData)
            }
        }
    }

    func reset() {
        self.processState = .none
        self.downloadedData = nil
        self.failureData = nil
        self.custards = nil
    }

    func finish(custard: Custard) {
        self.custards?.removeAll(where: {$0.identifier == custard.identifier})
    }

    private func process(data: Data) -> [Custard]? {
        self.processState = .processFile
        do {
            let custard = try JSONDecoder().decode(Custard.self, from: data)
            self.processState = .none
            return [custard]
        } catch {
            debug("ImportedCustardData process", error)
        }
        do {
            let custards = try JSONDecoder().decode([Custard].self, from: data)
            self.processState = .none
            return custards
        } catch {
            debug("ImportedCustardData process", error)
        }
        self.failureData = .invalidFile
        self.downloadedData = nil
        self.processState = .none
        return nil
    }

    func download(from urlString: String) {
        self.processState = .getURL
        guard let url = URL(string: urlString) else {
            self.failureData = .invalidURL
            self.processState = .none
            return
        }
        self.download(from: url)
    }

    func download(from url: URL) {
        Task {
            await self.downloadAsync(from: url)
        }
    }

    @MainActor
    private func downloadAsync(from url: URL) async {
        do {
            self.processState = .getFile
            guard !url.absoluteString.hasPrefix("file:///") || url.startAccessingSecurityScopedResource() else {
                self.processState = .none
                self.failureData = .invalidURL
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            self.downloadedData = data
            debug("downloadAsync succeed", data.count)
        } catch {
            debug("downloadAsync error", error)
            self.failureData = .invalidData
            self.processState = .none
        }
    }
}

struct WebCustardList: Codable {
    struct Item: Codable {
        var name: String
        var file: String
    }
    var last_update: String
    var custards: [Item]
}

struct ManageCustardView: View {
    @ObservedObject private var data = ImportedCustardData()
    @State private var urlString: String = ""
    @State private var showAlert = false
    @State private var alertType = AlertType.none
    @Binding private var manager: CustardManager
    @State private var webCustards: WebCustardList = .init(last_update: "", custards: [])
    @State private var showDocumentPicker = false
    @State private var selectedDocument: Data = Data()
    @State private var addTabBar = true
    init(manager: Binding<CustardManager>) {
        self._manager = manager
    }

    var body: some View {
        Form {
            Section(header: Text("一覧")) {
                if manager.availableCustards.isEmpty {
                    Text("カスタムタブがまだありません")
                } else {
                    List {
                        ForEach(manager.availableCustards, id: \.self) {identifier in
                            if let custard = self.getCustard(identifier: identifier) {
                                NavigationLink(identifier, destination: CustardInformationView(custard: custard, manager: $manager))
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            manager.removeCustard(identifier: identifier)
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                            } else if let custardFileURL = self.getCustardFile(identifier: identifier) {
                                if #available(iOS 16, *) {
                                    ShareLink(item: custardFileURL) {
                                        Label("読み込みに失敗したカスタムタブ「\(identifier)」を書き出す", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .onAppear(perform: loadWebCustard)

            Section(header: Text("作る")) {
                Text("登録したい文字や単語を順番に書いていくだけでスクロール式のカスタムタブを作成することができます。")
                NavigationLink("スクロール式のカスタムタブを作る", destination: EditingScrollCustardView(manager: $manager))
                    .foregroundColor(.accentColor)
                Text("フリック式のカスタムタブを作成することができます。")
                NavigationLink("フリック式のカスタムタブを作る", destination: EditingTenkeyCustardView(manager: $manager))
                    .foregroundColor(.accentColor)
            }
            if let custards = data.custards {
                ForEach(custards, id: \.identifier) {custard in
                    Section(header: Text("読み込んだタブ")) {
                        Text("「\(custard.metadata.display_name)(\(custard.identifier))」の読み込みに成功しました")
                        CenterAlignedView {
                            KeyboardPreview(scale: 0.7, defaultTab: .custard(custard))
                        }
                        Toggle("タブバーに追加", isOn: $addTabBar)
                        Button("保存") {
                            if manager.availableCustards.contains(custard.identifier) {
                                self.showAlert = true
                                self.alertType = .overlapCustard(custard: custard)
                            } else {
                                self.saveCustard(custard: custard)
                            }
                        }
                    }
                }
                Button("キャンセル") {
                    urlString = ""
                    selectedDocument = Data()
                    data.reset()
                }
                .foregroundColor(.red)

            } else {
                Section(header: Text("おすすめ")) {
                    ForEach(webCustards.custards, id: \.file) {item in
                        HStack {
                            Button {
                                data.download(from: "https://azookey.netlify.app/static/custard/\(item.file)")
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 5)
                            }
                            Text(verbatim: item.name)
                        }
                    }
                }

                Section(header: Text("読み込む")) {
                    Button("iCloudから読み込む") {
                        showDocumentPicker = true
                    }
                }
                Section(header: Text("URLから読み込む"), footer: Text("\(systemImage: "doc.on.clipboard")を長押しでペースト")) {
                    HStack {
                        TextField("URLを入力", text: $urlString)
                            .submitLabel(.go)
                            .onSubmit {
                                data.download(from: urlString)
                            }
                        Divider()
                        PasteLongPressButton($urlString)
                            .padding(.horizontal, 5)
                    }
                    Button("読み込む") {
                        data.download(from: urlString)
                    }
                }
                if let text = data.processState.description {
                    ProgressView(text)
                }
                if let failure = data.failureData {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text(failure.description).foregroundColor(.red)
                    }
                }
                Section {
                    Text("カスタムタブをファイルとして外部で作成し、azooKeyに読み込むことができます。より高機能なタブの作成が可能です。詳しくは以下をご覧ください。")
                    FallbackLink("カスタムタブファイルの作り方", destination: "https://github.com/ensan-hcl/CustardKit")
                }
            }
        }
        .navigationBarTitle(Text("カスタムタブの管理"), displayMode: .inline)
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .none:
                return Alert(title: Text("アラート"))
            case let .overlapCustard(custard):
                return Alert(
                    title: Text("注意"),
                    message: Text("識別子\(custard.identifier)を持つカスタムタブが既に登録されています。上書きしますか？"),
                    primaryButton: .default(Text("上書き")) {
                        self.saveCustard(custard: custard)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: ["txt", "custard", "json"].compactMap {UTType(filenameExtension: $0, conformingTo: .text)}) {result in
            switch result {
            case let .success(url):
                if url.startAccessingSecurityScopedResource() {
                    data.download(from: url)
                } else {
                    debug("error: 不正なURL)")
                }
            case let .failure(error):
                debug(error)
            }
        }
    }

    private func saveCustard(custard: Custard) {
        do {
            try manager.saveCustard(custard: custard, metadata: .init(origin: .imported), updateTabBar: addTabBar)
            data.finish(custard: custard)
            MainAppFeedback.success()
            if self.isFinished {
                data.reset()
                urlString = ""
                selectedDocument = Data()
            }
        } catch {
            debug("saveCustard", error)
        }
    }

    private func getCustard(identifier: String) -> Custard? {
        do {
            let custard = try manager.custard(identifier: identifier)
            return custard
        } catch {
            debug(error)
            return nil
        }
    }

    private func getCustardFile(identifier: String) -> URL? {
        do {
            let url = try manager.custardFileIfExist(identifier: identifier)
            return url
        } catch {
            debug(error)
            return nil
        }
    }

    private func delete(at offsets: IndexSet) {
        let identifiers = offsets.map {manager.availableCustards[$0]}
        identifiers.forEach {
            manager.removeCustard(identifier: $0)
        }
    }

    private var isFinished: Bool {
        if let custards = data.custards {
            return custards.isEmpty
        }
        return true
    }

    private func loadWebCustard() {
        guard let url = URL(string: "https://azooKey.netlify.com/static/custard/all") else {
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data {
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(WebCustardList.self, from: data) else {
                    debug("Failed to load https://azooKey.netlify.com/static/custard/all")
                    return
                }

                DispatchQueue.main.async {
                    self.webCustards = decodedResponse
                }
            } else {
                debug("Fetch failed", error)
            }

        }.resume()
    }
}

// FIXME: ファイルを保存もキャンセルもしない状態で2つ目のファイルを読み込むとエラーになる
struct URLImportCustardView: View {
    @ObservedObject private var data = ImportedCustardData()
    @State private var showAlert = false
    @State private var alertType = AlertType.none
    @Binding private var manager: CustardManager
    @Binding private var url: URL?
    @State private var addTabBar = true

    init(manager: Binding<CustardManager>, url: Binding<URL?>) {
        self._manager = manager
        self._url = url
    }

    var body: some View {
        Form {
            if let custards = data.custards {
                ForEach(custards, id: \.identifier) {custard in
                    Section(header: Text("読み込んだタブ")) {
                        Text("「\(custard.metadata.display_name)(\(custard.identifier))」の読み込みに成功しました")
                        CenterAlignedView {
                            KeyboardPreview(scale: 0.7, defaultTab: .custard(custard))
                        }
                        Toggle("タブバーに追加", isOn: $addTabBar)
                        Button("保存") {
                            if manager.availableCustards.contains(custard.identifier) {
                                self.showAlert = true
                                self.alertType = .overlapCustard(custard: custard)
                            } else {
                                self.saveCustard(custard: custard)
                            }
                        }
                    }
                }
                Button("キャンセル") {
                    data.reset()
                    url = nil
                }
                .foregroundColor(.red)
            } else if let text = data.processState.description {
                Section(header: Text("読み込み中")) {
                    ProgressView(text)
                    Button("閉じる") {
                        data.reset()
                        url = nil
                    }
                    .foregroundColor(.accentColor)
                }
            } else {
                Section(header: Text("読み込み失敗")) {
                    if let failure = data.failureData {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text(failure.description).foregroundColor(.red)
                        }
                    }
                    Button("閉じる") {
                        data.reset()
                        url = nil
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        .onAppear {
            if let url {
                debug("URLImportCustardView", url)
                data.reset()
                data.download(from: url)
            }
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .none:
                return Alert(title: Text("アラート"))
            case let .overlapCustard(custard):
                return Alert(
                    title: Text("注意"),
                    message: Text("識別子\(custard.identifier)を持つカスタムタブが既に登録されています。上書きしますか？"),
                    primaryButton: .default(Text("上書き")) {
                        self.saveCustard(custard: custard)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func saveCustard(custard: Custard) {
        do {
            try manager.saveCustard(custard: custard, metadata: .init(origin: .imported), updateTabBar: addTabBar)
            data.finish(custard: custard)
            MainAppFeedback.success()
            if self.isFinished {
                data.reset()
                url = nil
            }
        } catch {
            debug("saveCustard", error)
        }
    }

    private var isFinished: Bool {
        if let custards = data.custards {
            return custards.isEmpty
        }
        return true
    }
}
