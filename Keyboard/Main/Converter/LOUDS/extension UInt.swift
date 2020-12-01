//
//  extension UInt64.swift
//  Keyboard
//
//  Created by β α on 2020/09/30.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

extension UInt8{
    internal static let prefixOne: UInt8 = 0b10000000
}

extension UInt64{
    internal static let prefixOne: UInt64 = 0b1000000000000000000000000000000000000000000000000000000000000000
    
    internal var uint8Array: [UInt8] {
        var bigEndian: UInt64 = self.bigEndian
        let count = MemoryLayout<UInt64>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }


    internal func uint8Array(_ index: Int) -> UInt8 {
        var bigEndian:UInt64 = self.bigEndian
        let count = MemoryLayout<UInt64>.size
        return withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)[index]
            }
        }
    }

}
