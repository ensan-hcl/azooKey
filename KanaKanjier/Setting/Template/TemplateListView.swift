//
//  TemplateListView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

final class TemplateDataList: ObservableObject {
    @Published var templates: [TemplateData] = []
}

extension TemplateData: Identifiable {
    var id: String {
        self.name
    }
}

// このモデルがNavigation状態を管理し、プレビューが遷移後も更新し続けるのを防ぐ
private final class NavigationModel: ObservableObject {
    @Published var linkSelection: Int?
}

// Listが大元のtemplatesを持ち、各EditingViewにBindingで渡して編集させる。
struct TemplateListView: View {
    private static let defaultData = [
        TemplateData(template: "<random type=\"int\" value=\"1,6\">", name: "サイコロ"),
        TemplateData(template: "<random type=\"double\" value=\"0,1\">", name: "乱数"),
        TemplateData(template: "<random type=\"string\" value=\"大吉,吉,凶\">", name: "おみくじ"),
        TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "今日"),
        TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"1\" deltaunit=\"86400\">", name: "明日"),
        TemplateData(template: "<date format=\"Gy年MM月dd日\" type=\"japanese\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "和暦")
    ]

    private static let dataFileName = "user_templates.json"
    @ObservedObject private var data = TemplateDataList()
    @ObservedObject private var navigationModel = NavigationModel()

    init() {
        let templates = TemplateData.load() ?? Self.defaultData
        self.data.templates = templates
    }

    var body: some View {
        Form {
            List {
                let validationInfo = data.templates.map {$0.name}
                ForEach($data.templates.identifiableItems) {value in
                    TimelineView(.periodic(from: Date(), by: 1.0)) { _ in
                        NavigationLink(destination: TemplateEditingView(value.$item, validationInfo: validationInfo), tag: value.index, selection: $navigationModel.linkSelection) {
                            HStack {
                                Text(value.item.name)
                                Spacer()
                                Text(value.item.previewString)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }.navigationBarTitle(Text("テンプレートの管理"), displayMode: .inline)
        .navigationBarItems(trailing: addButton)
        .onEnterBackground {_ in
            self.save()
        }
        .onDisappear {
            self.save()
        }
    }

    private var addButton: some View {
        Button {
            let core = "new_template"
            var number = 0
            var name = core
            while !data.templates.allSatisfy({$0.name != name}) {
                number += 1
                name = "\(core)#\(number)"
            }
            let newData = TemplateData(template: DateTemplateLiteral.example.export(), name: name)
            data.templates.append(newData)
        }label: {
            Image(systemName: "plus")
        }
    }

    private func delete(at offsets: IndexSet) {
        data.templates.remove(atOffsets: offsets)
    }

    private func save() {
        if let json = try? JSONEncoder().encode(self.data.templates) {
            guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(TemplateData.dataFileName) else {
                return
            }
            do {
                try json.write(to: url)
            } catch {
                debug(error)
            }
        }
    }
}
