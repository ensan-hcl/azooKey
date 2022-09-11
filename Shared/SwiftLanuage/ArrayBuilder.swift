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
        return values
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
}
