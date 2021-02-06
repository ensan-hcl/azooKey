//
//  FileTools.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation

struct FileTools{
    private init()

    static func saveTextFile(contents: String, to fileName: String, for ex: String = "txt"){
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            guard let data = contents.data(using: .utf8) else {
                debug("ファイルをutf8で保存できません")
                return
            }
            fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
        } catch {
            debug(error)
        }
    }

    static func readTextFile(to fileName: String, for ex: String = "txt") -> String {
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            let contents = try String.init(contentsOfFile: path.path)
            return contents
        } catch {
            debug(error)
        }
        return ""
    }

    static func removeTextFile(to fileName: String, for ex: String = "txt"){
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            try fileManager.removeItem(atPath: path.path)
        } catch {
            debug(error)
        }
    }
}
