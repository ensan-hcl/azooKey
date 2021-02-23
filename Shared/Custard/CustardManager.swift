//
//  CustardManager.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

struct CustardMetaData: Codable {
    var origin: Origin

    enum Origin: String, Codable {
        case userMade
        case imported
    }
}

struct CustardManagerIndex: Codable {
    var availableCustards: [String] = []
    var availableTabBars: [Int] = []
    var metadata: [String: CustardMetaData] = [:]

    enum CodingKeys: CodingKey{
        case availableCustards
        case availableTabBars
        case metadata
    }

    internal init(availableCustards: [String] = [], availableTabBars: [Int] = [], metadata: [String : CustardMetaData] = [:]) {
        self.availableCustards = availableCustards
        self.availableTabBars = availableTabBars
        self.metadata = metadata
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(availableCustards, forKey: .availableCustards)
        try container.encode(availableTabBars, forKey: .availableTabBars)
        try container.encode(metadata, forKey: .metadata)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.availableCustards = try container.decode([String].self, forKey: .availableCustards)
        self.availableTabBars = try container.decode([Int].self, forKey: .availableTabBars)
        self.metadata = try container.decode([String: CustardMetaData].self, forKey: .metadata)
    }
}

struct CustardManager {
    private static let directoryName = "custard/"
    private var index = CustardManagerIndex()

    private static func fileURL(name: String) -> URL {
        let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
        let url = directoryPath.appendingPathComponent(directoryName + name)
        return url
    }

    private static func directoryExistCheck() {
        let directoryPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)!
        let filePath = directoryPath.appendingPathComponent(directoryName).path
        if !FileManager.default.fileExists(atPath: filePath){
            do{
                debug("ファイルを新規作成")
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true)
            } catch {
                debug(error)
            }
        }
    }

    static func load() -> Self {
        directoryExistCheck()
        let themeIndexURL = fileURL(name: "index.json")
        do{
            let data = try Data(contentsOf: themeIndexURL)
            let index = try JSONDecoder().decode(CustardManagerIndex.self, from: data)
            debug(index)
            return self.init(index: index)
        } catch {
            debug(error)
            return self.init(index: CustardManagerIndex())
        }
    }

    func save() {
        let indexURL = Self.fileURL(name: "index.json")
        do {
            let data = try JSONEncoder().encode(self.index)
            try data.write(to: indexURL, options: .atomicWrite)
        } catch {
            debug(error)
        }
    }

    func custard(identifier: String) throws -> Custard {
        let fileURL = Self.fileURL(name: "\(identifier)_main.custard")
        let data = try Data(contentsOf: fileURL)
        let custard = try JSONDecoder().decode(Custard.self, from: data)
        return custard
    }

    func tabbar(identifier: Int) throws -> TabBarData {
        let fileURL = Self.fileURL(name: "tabbar_\(identifier).tabbar")
        let data = try Data(contentsOf: fileURL)
        let custard = try JSONDecoder().decode(TabBarData.self, from: data)
        return custard
    }

    mutating func saveCustard(custard: Custard, metadata: CustardMetaData) throws {
        //テーマを保存する
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(custard)
            let fileURL = Self.fileURL(name: "\(custard.identifier)_main.custard")
            try data.write(to: fileURL)
        }

        if !self.index.availableCustards.contains(custard.identifier){
            self.index.availableCustards.append(custard.identifier)
        }
        self.index.metadata[custard.identifier] = metadata
        self.save()
    }

    mutating func saveTabBarData(tabBarData: TabBarData) throws {
        //テーマを保存する
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(tabBarData)
            let fileURL = Self.fileURL(name: "tabbar_\(tabBarData.identifier).tabbar")
            try data.write(to: fileURL)
        }

        if !self.index.availableTabBars.contains(tabBarData.identifier){
            self.index.availableTabBars.append(tabBarData.identifier)
        }
        self.save()
    }

    mutating func removeCustard(identifier: String){
        do{
            let fileURL = Self.fileURL(name: "\(identifier)_main.custard")
            try FileManager.default.removeItem(atPath: fileURL.path)
            self.index.availableCustards.removeAll{$0 == identifier}
            self.index.metadata.removeValue(forKey: identifier)
            self.save()
        }catch{
            debug(error)
        }
    }

    mutating func removeTabBar(identifier: Int){
        do{
            let fileURL = Self.fileURL(name: "tabbar_\(identifier).tabbar")
            try FileManager.default.removeItem(atPath: fileURL.path)
            self.index.availableTabBars = self.index.availableTabBars.filter{$0 != identifier}
            self.save()
        }catch{
            debug(error)
        }
    }


    var availableCustards: [String] {
        return index.availableCustards
    }

    var availableTabBars: [Int] {
        return index.availableTabBars
    }

    var metadata: [String: CustardMetaData] {
        return index.metadata
    }

}
