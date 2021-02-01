//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
extension Collection {
    /// Returns the first k elements of this collection when it's sorted using
    /// the given predicate as the comparison between elements.
    ///
    /// This example partially sorts an array of integers to retrieve its three
    /// smallest values:
    ///
    ///     let numbers = [7,1,6,2,8,3,9]
    ///     let smallestThree = numbers.sortedPrefix(3, by: <)
    ///     // [1, 2, 3]
    ///
    /// If you need to sort a collection but only need access to a prefix of its
    /// elements, using this method can give you a performance boost over sorting
    /// the entire collection. The order of equal elements is guaranteed to be
    /// preserved.
    ///
    /// - Parameter count: The k number of elements to prefix.
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its
    /// first argument should be ordered before its second argument;
    /// otherwise, false.
    ///
    /// - Complexity: O(k log k + nk)
    public func sortedPrefix(
        _ count: Int,
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Self.Element] {
        assert(count >= 0, """
      Cannot prefix with a negative amount of elements!
      """
        )

        // Do nothing if we're prefixing nothing.
        guard count > 0 else {
            return []
        }

        // Make sure we are within bounds.
        let prefixCount = Swift.min(count, self.count)

        // If we're attempting to prefix more than 10% of the collection, it's
        // faster to sort everything.
        guard prefixCount < (self.count / 10) else {
            return Array(try sorted(by: areInIncreasingOrder).prefix(prefixCount))
        }

        var result = try self.prefix(prefixCount).sorted(by: areInIncreasingOrder)
        for e in self.dropFirst(prefixCount) {
            if let last = result.last, try areInIncreasingOrder(last, e) {
                continue
            }
            let insertionIndex =
                try result.partitioningIndex { try areInIncreasingOrder(e, $0) }
            let isLastElement = insertionIndex == result.endIndex
            result.removeLast()
            if isLastElement {
                result.append(e)
            } else {
                result.insert(e, at: insertionIndex)
            }
        }

        return result
    }
}

extension Collection where Element: Comparable {
    /// Returns the first k elements of this collection when it's sorted in
    /// ascending order.
    ///
    /// This example partially sorts an array of integers to retrieve its three
    /// smallest values:
    ///
    ///     let numbers = [7,1,6,2,8,3,9]
    ///     let smallestThree = numbers.sortedPrefix(3)
    ///     // [1, 2, 3]
    ///
    /// If you need to sort a collection but only need access to a prefix of its
    /// elements, using this method can give you a performance boost over sorting
    /// the entire collection. The order of equal elements is guaranteed to be
    /// preserved.
    ///
    /// - Parameter count: The k number of elements to prefix.
    ///
    /// - Complexity: O(k log k + nk)
    public func sortedPrefix(_ count: Int) -> [Element] {
        return sortedPrefix(count, by: <)
    }
}
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// stablePartition(by:)
//===----------------------------------------------------------------------===//
extension MutableCollection {
    /// Moves all elements satisfying `belongsInSecondPartition` into a suffix
    /// of the collection, preserving their relative order, and returns the
    /// start of the resulting suffix.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the number of elements.
    /// - Precondition:
    ///   `n == distance(from: range.lowerBound, to: range.upperBound)`
    @usableFromInline
    internal mutating func stablePartition(
        count n: Int,
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws-> Bool
    ) rethrows -> Index {
        if n == 0 { return subrange.lowerBound }
        if n == 1 {
            return try belongsInSecondPartition(self[subrange.lowerBound])
                ? subrange.lowerBound
                : subrange.upperBound
        }

        let h = n / 2, i = index(subrange.lowerBound, offsetBy: h)
        let j = try stablePartition(
            count: h,
            subrange: subrange.lowerBound..<i,
            by: belongsInSecondPartition)
        let k = try stablePartition(
            count: n - h,
            subrange: i..<subrange.upperBound,
            by: belongsInSecondPartition)
        return rotate(subrange: j..<k, toStartAt: i)
    }

    /// Moves all elements satisfying the given predicate into a suffix of the
    /// given range, preserving the relative order of the elements in both
    /// partitions, and returns the start of the resulting suffix.
    ///
    /// - Parameters:
    ///   - subrange: The range of elements within this collection to partition.
    ///   - belongsInSecondPartition: A predicate used to partition the
    ///     collection. All elements satisfying this predicate are ordered after
    ///     all elements not satisfying it.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
    @inlinable
    public mutating func stablePartition(
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws-> Bool
    ) rethrows -> Index {
        try stablePartition(
            count: distance(from: subrange.lowerBound, to: subrange.upperBound),
            subrange: subrange,
            by: belongsInSecondPartition)
    }

    /// Moves all elements satisfying the given predicate into a suffix of this
    /// collection, preserving the relative order of the elements in both
    /// partitions, and returns the start of the resulting suffix.
    ///
    /// - Parameter belongsInSecondPartition: A predicate used to partition the
    ///   collection. All elements satisfying this predicate are ordered after
    ///   all elements not satisfying it.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
    @inlinable
    public mutating func stablePartition(
        by belongsInSecondPartition: (Element) throws-> Bool
    ) rethrows -> Index {
        try stablePartition(
            subrange: startIndex..<endIndex,
            by: belongsInSecondPartition)
    }
}

//===----------------------------------------------------------------------===//
// partition(by:)
//===----------------------------------------------------------------------===//
extension MutableCollection {
    /// Moves all elements satisfying `isSuffixElement` into a suffix of the
    /// collection, returning the start position of the resulting suffix.
    ///
    /// - Complexity: O(*n*) where n is the length of the collection.
    @inlinable
    public mutating func partition(
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        // This version of `partition(subrange:)` is half stable; the elements in
        // the first partition retain their original relative order.
        guard var i = try self[subrange].firstIndex(where: belongsInSecondPartition)
        else { return subrange.upperBound }

        var j = index(after: i)
        while j != subrange.upperBound {
            if try !belongsInSecondPartition(self[j]) {
                swapAt(i, j)
                formIndex(after: &i)
            }
            formIndex(after: &j)
        }

        return i
    }
}

extension MutableCollection where Self: BidirectionalCollection {
    /// Moves all elements satisfying `isSuffixElement` into a suffix of the
    /// collection, returning the start position of the resulting suffix.
    ///
    /// - Complexity: O(*n*) where n is the length of the collection.
    @inlinable
    public mutating func partition(
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        var lo = subrange.lowerBound
        var hi = subrange.upperBound

        // 'Loop' invariants (at start of Loop, all are true):
        // * lo < hi
        // * predicate(self[i]) == false, for i in startIndex ..< lo
        // * predicate(self[i]) == true, for i in hi ..< endIndex
        Loop: while true {
            FindLo: repeat {
                while lo < hi {
                    if try belongsInSecondPartition(self[lo]) { break FindLo }
                    formIndex(after: &lo)
                }
                break Loop
            } while false

            FindHi: repeat {
                formIndex(before: &hi)
                while lo < hi {
                    if try !belongsInSecondPartition(self[hi]) { break FindHi }
                    formIndex(before: &hi)
                }
                break Loop
            } while false

            swapAt(lo, hi)
            formIndex(after: &lo)
        }

        return lo
    }
}

//===----------------------------------------------------------------------===//
// partitioningIndex(where:)
//===----------------------------------------------------------------------===//
extension Collection {
    /// Returns the index of the first element in the collection that matches
    /// the predicate.
    ///
    /// The collection must already be partitioned according to the predicate.
    /// That is, there should be an index `i` where for every element in
    /// `collection[..<i]` the predicate is `false`, and for every element
    /// in `collection[i...]` the predicate is `true`.
    ///
    /// - Parameter belongsInSecondPartition: A predicate that partitions the
    ///   collection.
    /// - Returns: The index of the first element in the collection for which
    ///   `predicate` returns `true`.
    ///
    /// - Complexity: O(log *n*), where *n* is the length of this collection if
    ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
    @inlinable
    public func partitioningIndex(
        where belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        var n = count
        var l = startIndex

        while n > 0 {
            let half = n / 2
            let mid = index(l, offsetBy: half)
            if try belongsInSecondPartition(self[mid]) {
                n = half
            } else {
                l = index(after: mid)
                n -= half + 1
            }
        }
        return l
    }
}
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// reverse(subrange:)
//===----------------------------------------------------------------------===//
extension MutableCollection where Self: BidirectionalCollection {
    /// Reverses the elements of the collection, moving from each end until
    /// `limit` is reached from either direction. The returned indices are the
    /// start and end of the range of unreversed elements.
    ///
    ///     Input:
    ///     [a b c d e f g h i j k l m n o p]
    ///             ^
    ///           limit
    ///     Output:
    ///     [p o n m e f g h i j k l d c b a]
    ///             ^               ^
    ///             f               l
    ///
    /// - Postcondition: For returned indices `(f, l)`:
    ///   `f == limit || l == limit`
    @usableFromInline
    @discardableResult
    internal mutating func _reverse(
        subrange: Range<Index>, until limit: Index
    ) -> (Index, Index) {
        var f = subrange.lowerBound
        var l = subrange.upperBound
        while f != limit && l != limit {
            formIndex(before: &l)
            swapAt(f, l)
            formIndex(after: &f)
        }
        return (f, l)
    }

    /// Reverses the elements within the given subrange.
    ///
    /// This example reverses the numbers within the subrange at the start of the
    /// `numbers` array:
    ///
    ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    ///     numbers.reverse(subrange: 0..<4)
    ///     // numbers == [40, 30, 20, 10, 50, 60, 70, 80]
    ///
    /// - Parameter subrange: The subrange of this collection to reverse.
    ///
    /// - Complexity: O(*n*), where *n* is the length of `subrange`.
    @inlinable
    public mutating func reverse(subrange: Range<Index>) {
        if subrange.isEmpty { return }
        var lo = subrange.lowerBound
        var hi = subrange.upperBound

        while lo < hi {
            formIndex(before: &hi)
            swapAt(lo, hi)
            formIndex(after: &lo)
        }
    }
}

//===----------------------------------------------------------------------===//
// rotate(toStartAt:) / rotate(subrange:toStartAt:)
//===----------------------------------------------------------------------===//
extension MutableCollection {
    /// Swaps the elements of the two given subranges, up to the upper bound of
    /// the smaller subrange. The returned indices are the ends of the two
    /// ranges that were actually swapped.
    ///
    ///     Input:
    ///     [a b c d e f g h i j k l m n o p]
    ///      ^^^^^^^         ^^^^^^^^^^^^^
    ///      lhs             rhs
    ///
    ///     Output:
    ///     [i j k l e f g h a b c d m n o p]
    ///             ^               ^
    ///             p               q
    ///
    /// - Precondition: !lhs.isEmpty && !rhs.isEmpty
    /// - Postcondition: For returned indices `(p, q)`:
    ///
    ///   - distance(from: lhs.lowerBound, to: p) == distance(from:
    ///     rhs.lowerBound, to: q)
    ///   - p == lhs.upperBound || q == rhs.upperBound
    @usableFromInline
    internal mutating func _swapNonemptySubrangePrefixes(
        _ lhs: Range<Index>, _ rhs: Range<Index>
    ) -> (Index, Index) {
        assert(!lhs.isEmpty)
        assert(!rhs.isEmpty)

        var p = lhs.lowerBound
        var q = rhs.lowerBound
        repeat {
            swapAt(p, q)
            formIndex(after: &p)
            formIndex(after: &q)
        }
        while p != lhs.upperBound && q != rhs.upperBound
        return (p, q)
    }

    /// Rotates the elements within the given subrange so that the element
    /// at the specified index becomes the start of the subrange.
    ///
    /// Rotating a collection is equivalent to breaking the collection into two
    /// sections at the index `newStart`, and then swapping those two sections.
    /// In this example, the `numbers` array is rotated so that the element at
    /// index `3` (`40`) is first:
    ///
    ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    ///     let oldStart = numbers.rotate(subrange: 0..<4, toStartAt: 2)
    ///     // numbers == [30, 40, 10, 20, 50, 60, 70, 80]
    ///     // numbers[oldStart] == 10
    ///
    /// - Parameters:
    ///   - subrange: The subrange of this collection to rotate.
    ///   - newStart: The index of the element that should be at the start of
    ///     `subrange` after rotating.
    /// - Returns: The new index of the element that was at the start of
    ///   `subrange` pre-rotation.
    ///
    /// - Complexity: O(*n*), where *n* is the length of `subrange`.
    @inlinable
    @discardableResult
    public mutating func rotate(
        subrange: Range<Index>,
        toStartAt newStart: Index
    ) -> Index {
        var m = newStart, s = subrange.lowerBound
        let e = subrange.upperBound

        // Handle the trivial cases
        if s == m { return e }
        if m == e { return s }

        // We have two regions of possibly-unequal length that need to be
        // exchanged.  The return value of this method is going to be the
        // position following that of the element that is currently last
        // (element j).
        //
        //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
        //   ^             ^     ^        ^     ^             ^
        //   s             m     e        s     m             e
        //
        var ret = e // start with a known incorrect result.
        while true {
            // Exchange the leading elements of each region (up to the
            // length of the shorter region).
            //
            //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
            //    ^^^^^         ^^^^^          ^^^^^ ^^^^^
            //   [h i j d e f g|a b c]   or   [d e f|a b c g h i j]
            //   ^     ^       ^     ^         ^    ^     ^       ^
            //   s    s1       m    m1/e       s   s1/m   m1      e
            //
            let (s1, m1) = _swapNonemptySubrangePrefixes(s..<m, m..<e)

            if m1 == e {
                // Left-hand case: we have moved element j into position.  if
                // we haven't already, we can capture the return value which
                // is in s1.
                //
                // Note: the STL breaks the loop into two just to avoid this
                // comparison once the return value is known.  I'm not sure
                // it's a worthwhile optimization, though.
                if ret == e { ret = s1 }

                // If both regions were the same size, we're done.
                if s1 == m { break }
            }

            // Now we have a smaller problem that is also a rotation, so we
            // can adjust our bounds and repeat.
            //
            //    h i j[d e f g|a b c]   or    d e f[a b c|g h i j]
            //         ^       ^     ^              ^     ^       ^
            //         s       m     e              s     m       e
            s = s1
            if s == m { m = m1 }
        }

        return ret
    }

    /// Rotates the elements of this collection so that the element
    /// at the specified index becomes the start of the collection.
    ///
    /// Rotating a collection is equivalent to breaking the collection into two
    /// sections at the index `newStart`, and then swapping those two sections.
    /// In this example, the `numbers` array is rotated so that the element at
    /// index `3` (`40`) is first:
    ///
    ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    ///     let oldStart = numbers.rotate(toStartAt: 3)
    ///     // numbers == [40, 50, 60, 70, 80, 10, 20, 30]
    ///     // numbers[oldStart] == 10
    ///
    /// - Parameter newStart: The index of the element that should be first after
    ///   rotating.
    /// - Returns: The new index of the element that was first pre-rotation.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable
    @discardableResult
    public mutating func rotate(toStartAt newStart: Index) -> Index {
        rotate(subrange: startIndex..<endIndex, toStartAt: newStart)
    }
}

extension MutableCollection where Self: BidirectionalCollection {
    /// Rotates the elements within the given subrange so that the element
    /// at the specified index becomes the start of the subrange.
    ///
    /// Rotating a collection is equivalent to breaking the collection into two
    /// sections at the index `newStart`, and then swapping those two sections.
    /// In this example, the `numbers` array is rotated so that the element at
    /// index `3` (`40`) is first:
    ///
    ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    ///     let oldStart = numbers.rotate(subrange: 0..<4, toStartAt: 2)
    ///     // numbers == [30, 40, 10, 20, 50, 60, 70, 80]
    ///     // numbers[oldStart] == 10
    ///
    /// - Parameters:
    ///   - subrange: The subrange of this collection to rotate.
    ///   - newStart: The index of the element that should be at the start of
    ///     `subrange` after rotating.
    /// - Returns: The new index of the element that was at the start of
    ///   `subrange` pre-rotation.
    ///
    /// - Complexity: O(*n*), where *n* is the length of `subrange`.
    @inlinable
    @discardableResult
    public mutating func rotate(
        subrange: Range<Index>,
        toStartAt newStart: Index
    ) -> Index {
        reverse(subrange: subrange.lowerBound..<newStart)
        reverse(subrange: newStart..<subrange.upperBound)
        let (p, q) = _reverse(subrange: subrange, until: newStart)
        reverse(subrange: p..<q)
        return newStart == p ? q : p
    }

    /// Rotates the elements of this collection so that the element
    /// at the specified index becomes the start of the collection.
    ///
    /// Rotating a collection is equivalent to breaking the collection into two
    /// sections at the index `newStart`, and then swapping those two sections.
    /// In this example, the `numbers` array is rotated so that the element at
    /// index `3` (`40`) is first:
    ///
    ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    ///     let oldStart = numbers.rotate(toStartAt: 3)
    ///     // numbers == [40, 50, 60, 70, 80, 10, 20, 30]
    ///     // numbers[oldStart] == 10
    ///
    /// - Parameter newStart: The index of the element that should be first after
    ///   rotating.
    /// - Returns: The new index of the element that was first pre-rotation.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable
    @discardableResult
    public mutating func rotate(toStartAt newStart: Index) -> Index {
        rotate(subrange: startIndex..<endIndex, toStartAt: newStart)
    }
}

// Deprecations
extension MutableCollection {
    @available(*, deprecated, renamed: "rotate(subrange:toStartAt:)")
    @discardableResult
    public mutating func rotate(
        subrange: Range<Index>,
        at newStart: Index) -> Index
    {
        rotate(subrange: subrange, toStartAt: newStart)
    }

    @available(*, deprecated, renamed: "rotate(toStartAt:)")
    @discardableResult
    public mutating func rotate(at newStart: Index) -> Index {
        rotate(toStartAt: newStart)
    }
}
