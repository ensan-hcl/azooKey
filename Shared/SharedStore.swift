//
//  SharedStore.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum SharedStore {
    static let bundleName = "DevEn3.azooKey.keyboard"
    static let appGroupKey = "group.com.azooKey.keyboard"
}

func debug(_ items: Any...) {
    #if DEBUG
    print(items.map {"\($0)"}.joined(separator: " "))
    #endif
}

extension StringProtocol {
    // エスケープが必要なのは次の文字:
    /*
     \ -> \\
     \0 -> \0
     \n -> \n
     \t -> \t
     , -> \c
     " -> \d
     */
    // please use these letters in order to avoid user-inputting text crash
    func escaped() -> String {
        var result = self.replacingOccurrences(of: "\\", with: "\\b")
        result = result.replacingOccurrences(of: "\0", with: "\\0")
        result = result.replacingOccurrences(of: "\n", with: "\\n")
        result = result.replacingOccurrences(of: "\t", with: "\\t")
        result = result.replacingOccurrences(of: ",", with: "\\c")
        result = result.replacingOccurrences(of: " ", with: "\\s")
        result = result.replacingOccurrences(of: "\"", with: "\\d")
        return result
    }

    func unescaped() -> String {
        var result = self.replacingOccurrences(of: "\\d", with: "\"")
        result = result.replacingOccurrences(of: "\\s", with: " ")
        result = result.replacingOccurrences(of: "\\c", with: ",")
        result = result.replacingOccurrences(of: "\\t", with: "\t")
        result = result.replacingOccurrences(of: "\\n", with: "\n")
        result = result.replacingOccurrences(of: "\\0", with: "\0")
        result = result.replacingOccurrences(of: "\\b", with: "\\")
        return result
    }

}
