//
//  BindingTranslator.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/12.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI
/*
 public protocol Intertranslator {
 associatedtype First
 associatedtype Second

 static func convert(_ first: First) -> Second
 static func convert(_ second: Second) -> First

 static func convert(_ second: Second, current: First?) -> First
 }

 extension Intertranslator {
 static func convert(_ second: Second, current: First?) -> First {
 return Self.convert(second)
 }
 }

 @propertyWrapper
 public struct BindingTranslate<T, Translator: Intertranslator> {
 public var wrappedValue: WritableKeyPath<T, Translator.First>

 public var projectedValue: Self {
 return self
 }

 public init(wrappedValue: WritableKeyPath<T, Translator.First>){
 self.wrappedValue = wrappedValue
 }
 }

 private class ReferenceStorage<T>{
 var value: T
 init(_ value: T){
 self.value = value
 }
 }

 @propertyWrapper
 public struct BindingStorageTranslate<T, Translator: Intertranslator> {
 public var wrappedValue: WritableKeyPath<T, Translator.Second>
 fileprivate var storage: ReferenceStorage<Translator.First?> = .init(nil)

 public var projectedValue: Self {
 return self
 }

 public init(wrappedValue: WritableKeyPath<T, Translator.Second>){
 self.wrappedValue = wrappedValue
 }
 }


 public extension Binding {
 func translated<Translator: Intertranslator>(_ mixPath: BindingTranslate<Value, Translator>) -> Binding<Translator.Second> {
 Binding<Translator.Second>(get: {
 let mainValue = self.wrappedValue[keyPath: mixPath.wrappedValue]
 return Translator.convert(mainValue)
 }, set: {newValue in
 self.wrappedValue[keyPath: mixPath.wrappedValue] = Translator.convert(newValue)
 })
 }

 func translated<Translator: Intertranslator>(_ storage: BindingStorageTranslate<Value, Translator>) -> Binding<Translator.First> {
 Binding<Translator.First>(get: {
 if let value = storage.storage.value{
 return value
 }
 let subValue = self.wrappedValue[keyPath: storage.wrappedValue]
 let mainValue = Translator.convert(subValue, current: storage.storage.value)
 storage.storage.value = mainValue
 return mainValue
 }, set: {newValue in
 storage.storage.value = newValue
 self.wrappedValue[keyPath: storage.wrappedValue] = Translator.convert(newValue)
 })
 }
 }
 */
