//
//  TopNing.swift
//  KanaKanjierTests
//
//  Created by β α on 2020/10/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import XCTest

extension String{
    func contains(_ characterSet: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: characterSet).count < self.count
    }

    func only2(_ characterSet: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: characterSet).isEmpty
    }

    //最速(2020-11-31)
    func isRomanReg() -> Bool{
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    //めっちゃ速い
    func contains2(_ characterSet: CharacterSet) -> Bool {
        for scalar in self.unicodeScalars where characterSet.contains(scalar){
            return true
        }
        return false
    }

    //めっちゃ速い
    func only(_ characterSet: CharacterSet) -> Bool {
        for scalar in self.unicodeScalars where !characterSet.contains(scalar){
            return false
        }
        return true
    }

    var isOnlyRoman: Bool {
        return self.allSatisfy{$0.isASCII && ($0.isLowercase || $0.isUppercase)}
    }

    //めっちゃ遅い
    var isRoman: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[a-zA-Z]+").evaluate(with: self)
    }

    //最悪
    var isRomanByInterSect: Bool {
        return !Self.romanAlphabetCharacter.intersection(self).isEmpty
    }

    func contains(_ characterSet: Set<Character>) -> Bool {
        for character in self where characterSet.contains(character){
            return true
        }
        return false
    }

    func contains(_ characterSet: [Character]) -> Bool {
        for character in self where characterSet.contains(character){
            return true
        }
        return false
    }


    static let romanAlphabetCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let romanAlphabetCharacter = Set<Character>("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let romanAlphabetCharacterArray = [Character]("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

}


class ContainTest: XCTestCase {
    let stringPattern = "0t亜ａｱあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも"
    let onlySet = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも"

    let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let times = 1000
    func testPerformance1() throws{
        let strings = (0..<100).map{_ in String((0..<1).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance10() throws{
        let strings = (0..<100).map{_ in String((0..<10).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance100() throws{
        let strings = (0..<100).map{_ in String((0..<100).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance1000() throws{
        let strings = (0..<100).map{_ in String((0..<1000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance10000() throws{
        let strings = (0..<100).map{_ in String((0..<10000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance100000() throws{
        let strings = (0..<100).map{_ in String((0..<100000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }
}

class OnlyRomanTest: XCTestCase {
    let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let times = 1
    func testPerformance100000ASCII() throws{
        let string = String.init(repeating: "abc", count: 100000)
        let strings = [String].init(repeating: string, count: 100)
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.isOnlyRoman
                }
            }
        }
    }

    func testPerformance100000Trim() throws{
        let string = String.init(repeating: "abc", count: 100000)
        let strings = [String].init(repeating: string, count: 100)
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.only2(self.characterSet)
                }
            }
        }
    }

    func testPerformance100000Reg() throws{
        let string = String.init(repeating: "abc", count: 100000)
        let strings = [String].init(repeating: string, count: 100)
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    print(string.isRomanReg())
                }
            }
        }
    }



    func testPerformance100000Only() throws{
        let string = String.init(repeating: "abc", count: 100000)
        let strings = [String].init(repeating: string, count: 100)
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.only(self.characterSet)
                }
            }
        }
    }
}

class OnlyTest: XCTestCase {
    let stringPattern = "0t亜ａｱあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも"
    let characterSet = CharacterSet(charactersIn: "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも")
    let times = 1000
    func testPerformance1() throws{
        let strings = (0..<100).map{_ in String((0..<1).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance10() throws{
        let strings = (0..<100).map{_ in String((0..<10).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance100() throws{
        let strings = (0..<100).map{_ in String((0..<100).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance1000() throws{
        let strings = (0..<100).map{_ in String((0..<1000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance10000() throws{
        let strings = (0..<100).map{_ in String((0..<10000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }

    func testPerformance100000() throws{
        let strings = (0..<100).map{_ in String((0..<100000).map{ _ in stringPattern.randomElement()!})}
        self.measure {
            strings.forEach{string in
                (0..<times).forEach{_ in
                    let bool = string.contains2(characterSet)
                }
            }
        }
    }
}

class SetTest: XCTestCase {

    func testPerformanceCharSet() throws{
        let strings = (0..<100000).map{_ in String((0..<100).map{ _ in "tあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも".randomElement()!})}
        self.measure {
            strings.forEach{
                let bool = $0.contains(String.romanAlphabetCharacterSet)
            }
        }
    }

    func testPerformanceCharSetFor() throws{
        let strings = (0..<100000).map{_ in String((0..<100).map{ _ in "tあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも".randomElement()!})}
        self.measure {
            strings.forEach{
                let bool = $0.contains2(String.romanAlphabetCharacterSet)
            }
        }
    }



    func testPerformanceSetCharacter() throws{
        let strings = (0..<100000).map{_ in String((0..<100).map{ _ in "tあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも".randomElement()!})}
        self.measure {
            strings.forEach{
                let bool = $0.contains(String.romanAlphabetCharacter)
            }
        }
    }

    func testPerformanceIsRoman() throws{
        let strings = (0..<100000).map{_ in String((0..<100).map{ _ in "tあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも".randomElement()!})}
        self.measure {
            strings.forEach{
                let bool = $0.isRomanByInterSect
            }
        }
    }



    func testperformanceSetUpdate() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var set: Set<Int> = []
        measure{
            values.forEach{(value: Int) in
                set.update(with: value)
            }
        }
        print(set.count)
    }

    func testperformanceSetInsert() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var set: Set<Int> = []
        measure{
            values.forEach{(value: Int) in
                set.insert(value)
            }
        }
        print(set.count)
    }

    func testperformanceSet() throws{
        let values = (0..<1000000).map{_ in Int.random(in: 0..<10000000)}
        var set: Set<Int> = []
        measure{
            //set.formUnion(values)
            set = set.union(values)
            /*
            values.forEach{(value: Int) in
                set.formUnion([value])
            }
             */
        }
        print(set.count)
    }

}
