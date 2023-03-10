//
//  Trie.swift
//  MainApp
//
//  Created by ensan on 2020/11/13.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

final class TrieNode<Key: Hashable, Value: Hashable> {
    var value: Set<Value>
    var children: [Key: TrieNode<Key, Value>]
    var id = -1

    init(value: [Value] = [], children: [Key: TrieNode<Key, Value>] = [:]) {
        self.value = Set(value)
        self.children = children
    }

    func findNode(for keys: [Key]) -> TrieNode<Key, Value>? {
        var current: TrieNode<Key, Value> = self
        for key in keys {
            if let next = current.children[key] {
                current = next
            } else {
                return nil
            }
        }
        return current
    }

    func find(for keys: [Key]) -> Set<Value> {
        var current: TrieNode<Key, Value> = self
        for key in keys {
            if let next = current.children[key] {
                current = next
            } else {
                return []
            }
        }
        return current.value
    }

    func insertValue(for keys: [Key], value: Value) {
        var current: TrieNode<Key, Value> = self
        keys.forEach { key in
            if let next = current.children[key] {
                current = next
            } else {
                let newNode = TrieNode<Key, Value>()
                current.children[key] = newNode
                current = newNode
            }
        }
        current.value.update(with: value)
    }

    func insertValues(for keys: [Key], values: [Value]) {
        var current: TrieNode<Key, Value> = self
        keys.forEach { key in
            if let next = current.children[key] {
                current = next
            } else {
                let newNode = TrieNode<Key, Value>()
                current.children[key] = newNode
                current = newNode
            }
        }
        current.value = current.value.union(Set(values))
    }

    func prefix(for keys: [Key]) -> [Value] {
        if let node = self.findNode(for: keys) {
            return node.flatChildren()
        }
        return []
    }

    func flatChildren() -> [Value] {
        self.children.flatMap {$0.value.flatChildren()} + self.value
    }
}

extension TrieNode where Key == Character {
    func findNode(for keys: some StringProtocol) -> TrieNode<Key, Value>? {
        self.findNode(for: Array(keys))
    }

    func find(for keys: some StringProtocol) -> Set<Value> {
        self.find(for: Array(keys))
    }

    func insertValue(for keys: some StringProtocol, value: Value) {
        self.insertValue(for: Array(keys), value: value)
    }

    func insertValues(for keys: some StringProtocol, values: [Value]) {
        self.insertValues(for: Array(keys), values: values)
    }

    func prefix(for keys: some StringProtocol) -> [Value] {
        self.prefix(for: Array(keys))
    }
}
