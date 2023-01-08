//
//  ArrayBuilder.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Algorithms
import Foundation

@resultBuilder
struct ArrayBuilder {
    public static func buildBlock<T>(_ values: T...) -> [T] {
        values
    }
}

extension Sequence {
    /// Returns a sequence that contains the elements of this sequence followed by the elements of the given sequence.
    /// - Parameters:
    ///   - sequence: A sequence of elements to chain.
    /// - Returns: A sequence that contains the elements of this sequence followed by the elements of the given sequence.
    func chained<S: Sequence<Element>>(_ sequence: S) -> Chain2Sequence<Self, S> {
        chain(self, sequence)
    }
}

extension Collection {
    /// Returns a `Set` containing the elements of this sequence with transformed values.
    /// - Parameters:
    ///   - transform: A closure that transforms each element of this sequence into a value that can be hashed.
    /// - Returns: A `Set` containing the elements of this sequence.
    func mapSet<T>(transform closure: (Element) throws -> T) rethrows -> Set<T> {
        var set = Set<T>()
        set.reserveCapacity(self.count)
        for item in self {
            set.update(with: try closure(item))
        }
        return set
    }

    /// Returns a `Set` containing the elements of this sequence with transformed values.
    /// - Parameters:
    ///   - transform: A closure that transforms each element of this sequence into a sequence of values that can be hashed.
    /// - Returns: A `Set` containing the elements of this sequence.
    func flatMapSet<T: Sequence>(transform closure: (Element) throws -> T) rethrows -> Set<T.Element> {
        var set = Set<T.Element>()
        for item in self {
            set.formUnion(try closure(item))
        }
        return set
    }

    /// Returns a `Set` containing the non-nil elements of this sequence with transformed values.
    /// - Parameters:
    ///   - transform: A closure that transforms each element of this sequence into an optional value that can be hashed.
    /// - Returns: A `Set` containing the non-nil elements of this sequence.
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
    /// Calls the given closure with a pointer to the array's mutable contiguous storage.
    /// - Parameter 
    ///   - transform: A closure that takes a pointer to the array's mutable contiguous storage.
    mutating func mutatingForeach(transform closure: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try closure(&self[index])
        }
    }
}

extension Collection {
    /// Returns a SubSequence containing the elements of this sequence up to the first element that does not satisfy the given predicate.
    /// - Parameters:
    ///   - condition: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included.
    /// - Returns: A SubSequence containing the elements of this sequence up to the first element that does not satisfy the given predicate.
    func suffix(while condition: (Element) -> Bool) -> SubSequence {
        var left = self.endIndex
        while left != self.startIndex, condition(self[self.index(left, offsetBy: -1)]) {
            left = self.index(left, offsetBy: -1)
        }
        return self[left ..< self.endIndex]
    }
}

extension Collection where Self.Element: Equatable {
    /// Returns a Bool value indicating whether the collection has the given prefix.
    /// - Parameters:
    ///   - prefix: A collection to search for at the beginning of this collection.
    /// - Returns: A Bool value indicating whether the collection has the given prefix.
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

    /// Returns a Bool value indicating whether the collection has the given suffix.
    /// - Parameters:
    ///   - suffix: A collection to search for at the end of this collection.
    /// - Returns: A Bool value indicating whether the collection has the given suffix.
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

    /// Returns an Array containing the common prefix of this collection and the given collection.
    /// - Parameters:
    ///   - collection: A collection to search for a common prefix with this collection.
    /// - Returns: An Array containing the common prefix of this collection and the given collection.
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
