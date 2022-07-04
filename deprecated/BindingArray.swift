//
//  BindingArray.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/25.
//  Copyright © 2021 DevEn3. All rights reserved.
//
/*
 import Foundation
 import SwiftUI
 extension Binding: IteratorProtocol where Value: IteratorProtocol {
 public mutating func next() -> Binding<Value.Element>? {
 guard var item = wrappedValue.next() else {
 return nil
 }
 return Binding<Value.Element>(
 get: {
 item
 },
 set: {
 item = $0
 }
 )
 }
 }

 extension Binding: Identifiable where Value: Identifiable {
 public var id: Value.ID {
 wrappedValue.id
 }

 public typealias ID = Value.ID
 }

 extension Binding: Sequence where Value: BidirectionalCollection {
 public typealias Element = Binding<Value.Element>
 public typealias Iterator = Binding<Value.Iterator>

 public __consuming func makeIterator() -> Binding<Value.Iterator> {
 var iterator = wrappedValue.makeIterator()
 return Binding<Value.Iterator>(
 get: { iterator },
 set: { iterator = $0}
 )
 }
 }

 extension Binding: Collection where Value: BidirectionalCollection & MutableCollection {
 public subscript(position: Value.Index) -> Binding<Value.Element> {
 get {
 return Binding<Value.Element>(
 get: {
 return wrappedValue[position]
 },
 set: {
 wrappedValue[position] = $0
 }
 )
 }
 }

 public var startIndex: Value.Index {
 wrappedValue.startIndex
 }

 public var endIndex: Value.Index {
 wrappedValue.endIndex
 }

 public typealias Index = Value.Index
 }

 extension Binding: BidirectionalCollection where Value: BidirectionalCollection & MutableCollection {
 public func index(after i: Value.Index) -> Value.Index {
 wrappedValue.index(after: i)
 }

 public func index(before i: Value.Index) -> Value.Index {
 wrappedValue.index(before: i)
 }
 }

 extension Binding: RandomAccessCollection where Value: BidirectionalCollection & MutableCollection {}
 */
