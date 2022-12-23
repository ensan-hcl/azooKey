//
//  ArrayBuilder.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

@resultBuilder
struct ArrayBuilder {
    public static func buildBlock<T>(_ values: T...) -> [T] {
        values
    }
}

extension Collection {
    func mapSet<T>(transform closure: (Element) throws -> T) rethrows -> Set<T> {
        var set = Set<T>()
        set.reserveCapacity(self.count)
        for item in self {
            set.update(with: try closure(item))
        }
        return set
    }

    func flatMapSet<T: Sequence>(transform closure: (Element) throws -> T) rethrows -> Set<T.Element> {
        var set = Set<T.Element>()
        for item in self {
            set.formUnion(try closure(item))
        }
        return set
    }

    func compactMapSet<T>(transform closure: (Element) throws -> T?) rethrows -> Set<T> {
        var set = Set<T>()
        set.reserveCapacity(self.count)
        for item in self {
            if let value = try closure(item) {
                set.update(with: value)
            }
        }
        return set
    }
}

extension MutableCollection {
    mutating func mutatingForeach(transform closure: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try closure(&self[index])
        }
    }
}

extension Collection {
    func suffix(while condition: (Element) -> Bool) -> SubSequence {
        var left = self.endIndex
        while left != self.startIndex, condition(self[self.index(left, offsetBy: -1)]) {
            left = self.index(left, offsetBy: -1)
        }
        return self[left ..< self.endIndex]
    }
}

extension Collection where Self.Element: Equatable {
    func hasPrefix(_ prefix: some Collection<Element>) -> Bool {
        if self.count < prefix.count {
            return false
        }
        for (i, value) in prefix.enumerated() {
            if self[self.index(self.startIndex, offsetBy: i)] != value {
                return false
            }
        }
        return true
    }

    func hasSuffix(_ suffix: some Collection<Element>) -> Bool {
        if self.count < suffix.count {
            return false
        }
        let count = suffix.count
        for (i, value) in suffix.enumerated() {
            if self[self.index(self.endIndex, offsetBy: i - count)] != value {
                return false
            }
        }
        return true
    }

    func commonPrefix(with collection: some Collection<Element>) -> [Element] {
        var prefix: [Element] = []
        for (i, value) in self.enumerated() where i < collection.count {
            if value == collection[collection.index(collection.startIndex, offsetBy: i)] {
                prefix.append(value)
            } else {
                break
            }
        }
        return prefix
    }
}
