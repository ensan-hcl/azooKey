//
//  CustardManager.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import CryptoKit

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

    private static func fileName(_ identifier: String) -> String {
        let hash = SHA256.hash(data: identifier.data(using: .utf8) ?? Data())
        let value16 = hash.map{String.init($0, radix: 16, uppercase: true)}.joined()
        return value16
    }

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

    func userMadeCustardData(identifier: String) throws -> UserMadeCustard {
        let fileName = Self.fileName(identifier)
        let fileURL = Self.fileURL(name: "\(fileName)_edit.json")
        let data = try Data(contentsOf: fileURL)
        let userMadeCustard = try JSONDecoder().decode(UserMadeCustard.self, from: data)
        return userMadeCustard
    }

    func custard(identifier: String) throws -> Custard {
        let fileName = Self.fileName(identifier)
        let fileURL = Self.fileURL(name: "\(fileName)_main.custard")
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

    func checkTabExistInTabBar(identifier: Int = 0, tab: CodableTabData) -> Bool {
        guard let tabbar = try? self.tabbar(identifier: identifier) else {
            return false
        }
        return tabbar.items.contains(where: {$0.actions == [.moveTab(tab)]})
    }

    mutating func addTabBar(identifier: Int = 0, item: TabBarItem) throws {
        let tabbar = try self.tabbar(identifier: identifier)
        let newTabBar = TabBarData.init(
            identifier: tabbar.identifier,
            items: tabbar.items + [item]
        )
        try self.saveTabBarData(tabBarData: newTabBar)
    }

    mutating func saveCustard(custard: Custard, metadata: CustardMetaData, userData: UserMadeCustard? = nil, updateTabBar: Bool = false) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(custard)
        let fileName = Self.fileName(custard.identifier)
        let fileURL = Self.fileURL(name: "\(fileName)_main.custard")
        try data.write(to: fileURL)
        if let userData = userData {
            let fileURL = Self.fileURL(name: "\(fileName)_edit.json")
            let data = try encoder.encode(userData)
            try data.write(to: fileURL)
        }

        if !self.index.availableCustards.contains(custard.identifier){
            self.index.availableCustards.append(custard.identifier)
        }

        if updateTabBar && !self.checkTabExistInTabBar(tab: .custom(custard.identifier)){
            try self.addTabBar(item: .init(label: .text(custard.display_name), actions: [.moveTab(.custom(custard.identifier))]))
        }

        self.index.metadata[custard.identifier] = metadata
        self.save()
    }

    mutating func saveTabBarData(tabBarData: TabBarData) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(tabBarData)
        let fileURL = Self.fileURL(name: "tabbar_\(tabBarData.identifier).tabbar")
        try data.write(to: fileURL)
        if !self.index.availableTabBars.contains(tabBarData.identifier){
            self.index.availableTabBars.append(tabBarData.identifier)
        }
        self.save()
    }

    mutating func removeCustard(identifier: String){
        do{
            let fileName = Self.fileName(identifier)
            self.index.availableCustards.removeAll{$0 == identifier}
            self.index.metadata.removeValue(forKey: identifier)
            let fileURL = Self.fileURL(name: "\(fileName)_main.custard")
            try FileManager.default.removeItem(atPath: fileURL.path)
            let editFileURL = Self.fileURL(name: "\(fileName)_edit.json")
            try? FileManager.default.removeItem(atPath: editFileURL.path)
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

    func availableCustard(for language: KeyboardLanguage) -> [String] {
        switch language{
        case .japanese:
            return self.availableCustards.compactMap{
                if let custard = try? self.custard(identifier: $0){
                    if custard.language == .ja_JP{
                        return custard.identifier
                    }
                }
                return nil
            }
        case .greek:
            return self.availableCustards.compactMap{
                if let custard = try? self.custard(identifier: $0){
                    if custard.language == .el_GR{
                        return custard.identifier
                    }
                }
                return nil
            }
        case .english:
            return self.availableCustards.compactMap{
                if let custard = try? self.custard(identifier: $0){
                    if custard.language == .en_US{
                        return custard.identifier
                    }
                }
                return nil
            }
        case .none:
            return []
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
