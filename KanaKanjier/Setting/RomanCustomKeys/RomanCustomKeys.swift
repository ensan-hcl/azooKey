//
//  RomanCustomKeys.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/20.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct RomanCustomKey: Codable {
    let name: String
    let longpress: [String]
}

private struct RomanCustomKeysArray: Codable {
    let list: [RomanCustomKey]
}

struct RomanCustomKeys: Savable {
    typealias SaveValue = Data
    static let defaultValue = RomanCustomKeys(list: [
        (true,"。"),
        (false,"。"),
        (false,"."),
        (true,"、"),
        (false,"、"),
        (false,","),
        (true,"？"),
        (false,"？"),
        (false,"?"),
        (true,"！"),
        (false,"！"),
        (false,"!"),
        (true,"…"),
    ])

    var saveValue: SaveValue {
        var result: [RomanCustomKey] = []
        var currentMain: String? = nil
        var currentLongpress: [String] = []
        for item in list{
            if item.main{
                if let main = currentMain{
                    result.append(RomanCustomKey(name: main, longpress: currentLongpress))
                }
                currentMain = item.value
                currentLongpress = []
            }else{
                currentLongpress.append(item.value)
            }
        }
        if let main = currentMain{
            result.append(RomanCustomKey(name: main, longpress: currentLongpress))
        }
        print("save", result)
        let array = RomanCustomKeysArray(list: result)
        let encoder = JSONEncoder()
        if let encodedValue = try? encoder.encode(array) {
            return encodedValue
        }else{
            return Data()
        }
    }

    var keys: [RomanCustomKey] {
        var result: [RomanCustomKey] = []
        var currentMain: String? = nil
        var currentLongpress: [String] = []
        for item in list{
            if item.main{
                if let main = currentMain{
                    result.append(RomanCustomKey(name: main, longpress: currentLongpress))
                }
                currentMain = item.value
                currentLongpress = []
            }else{
                currentLongpress.append(item.value)
            }
        }
        if let main = currentMain{
            result.append(RomanCustomKey(name: main, longpress: currentLongpress))
        }
        return result
    }

    var list: [(main: Bool, value: String)] = []

    init(list: [(main: Bool, value: String)]){
        if list.isEmpty{
            self.list = Self.defaultValue.list
        }else{
            self.list = list
        }
    }

    func getKeyIndex(at index: Int) -> Int {
        return self.list[0...index].filter{$0.main}.count - 1
    }

    mutating func toggleMain(at index: Int){
        self.list[index].main.toggle()
        self.update()
    }

    mutating func update(){
        if self.list.isEmpty{
            return
        }
        if !self.list[0].main{
            self.list[0] = (true, self.list[0].value)
        }
    }

    mutating func remove(at offsets: IndexSet){
        self.list.remove(atOffsets: offsets)
        self.update()
    }


    mutating func move(at offsets: IndexSet, to index: Int){
        /*
        let indices = offsets.flatMap{(i: Int) -> [Int] in
            if self.list[i].main{
                if i == self.list.endIndex - 1{
                    return [i]
                }
                if let nextHead = (i+1..<self.list.endIndex).first{self.list[$0].main}{
                    return Array(i..<nextHead)
                }else{
                    return Array(i..<self.list.endIndex)
                }
            }else{
                return [i]
            }
        }
*/
        let items = offsets.map{self.list[$0]}
        self.list.remove(atOffsets: offsets)
        let removedCount = offsets.filter{$0 < index}.count
        let adjustedIndex = index-removedCount

        if adjustedIndex == 0{
            items.forEach{item in
                self.list.insert(item, at: 0)
            }
        }else if adjustedIndex == self.list.endIndex{
            items.forEach{item in
                self.list.append(item)
            }
        }else{
            let prev = self.list[adjustedIndex-1]
            let next = self.list[adjustedIndex]
            items.forEach{item in
                if !prev.main && !next.main{
                    self.list.insert((false, item.value), at: adjustedIndex)
                }else{
                    self.list.insert(item, at: adjustedIndex)
                }
            }
        }
        self.update()
    }

    mutating func add(){
        self.list.append((main: true, value: ""))
    }

    static func get(_ value: Any) -> RomanCustomKeys? {
        print(value)
        if let value = value as? SaveValue{
            let decoder = JSONDecoder()
            if let keys = try? decoder.decode(RomanCustomKeysArray.self, from: value) {
                let list = keys.list.flatMap{item in
                    return [(true, item.name)] + item.longpress.map{(false, $0)}
                }
                return RomanCustomKeys(list: list)
            }
        }
        return nil
    }
}
