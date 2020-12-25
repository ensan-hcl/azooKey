//
//  TemplateListView.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/19.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

final class TemplateDataList: ObservableObject {
    @Published var templates: [TemplateDataModel] = []
}

final class TemplateEditingViewVariableSection: ObservableObject {
    @Published var selection: TemplateLiteralType = .date
}

struct TemplateDataModel {
    var data: TemplateData
    let variableSection: TemplateEditingViewVariableSection

    init(_ data: TemplateData){
        self.data = data
        self.variableSection = TemplateEditingViewVariableSection()
        self.variableSection.selection = self.data.type
    }
}

//Listが大元のtemplatesを持ち、各EditingViewにBindingで渡して編集させる。
struct TemplateListView: View {
    static let defaultData = [
        TemplateData(template: "<random type=\"int\" value=\"1,6\">", name: "サイコロ"),
        TemplateData(template: "<random type=\"double\" value=\"0,1\">", name: "乱数"),
        TemplateData(template: "<random type=\"string\" value=\"大吉,吉,凶\">", name: "おみくじ"),
        TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "今日"),
        TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"1\" deltaunit=\"86400\">", name: "明日"),
        TemplateData(template: "<date format=\"Gy年MM月dd日\" type=\"japanese\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "和暦")
    ]
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    static let dataFileName = "user_templates.json"
    @ObservedObject private var data = TemplateDataList()
    @State private var previewStrings: [String] = []
    init(){
        if let savedData = TemplateData.load(){
            self.data.templates = savedData.map{TemplateDataModel($0)}
        } else {
            self.data.templates = Self.defaultData.map{TemplateDataModel($0)}
        }
        self._previewStrings = State(initialValue: data.templates.map{$0.data.previewString})
        self.update()
    }

    func update(){
        self.previewStrings = data.templates.map{$0.data.previewString}
    }

    var body: some View {
        Form{
            List{
                ForEach(data.templates.indices, id: \.self){i in
                    NavigationLink(destination: TemplateEditingView(data, index: i)){
                        HStack{
                            Text(data.templates[i].data.name)
                                Spacer()
                            Text(previewStrings[i])
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }.navigationBarTitle(Text("テンプレートの管理"), displayMode: .inline)
        .navigationBarItems(trailing: addButton)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)){_ in
            self.save()
        }
        .onDisappear{
            self.save()
        }
        .onReceive(timer){_ in
            self.update()
        }
    }

    var addButton: some View {
        Button{
            let core = "new_template"
            var number = 0
            var name = core
            while !data.templates.allSatisfy({$0.data.name != name}){
                number += 1
                name = "\(core)#\(number)"
            }
            let newData = TemplateData(template: DateTemplateLiteral.example.export(), name: name)
            data.templates.append(TemplateDataModel(newData))
            self.previewStrings.append(newData.previewString)
        }label: {
            Image(systemName: "plus")
        }
    }

    func delete(at offsets: IndexSet) {
        data.templates.remove(atOffsets: offsets)
        previewStrings.remove(atOffsets: offsets)
    }

    func save(){
        if let json = try? JSONEncoder().encode(self.data.templates.map{$0.data}){
            guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(TemplateData.dataFileName) else { return }
            do {
                try json.write(to: url)
            } catch {
                debug(error)
            }
        }
    }
}
