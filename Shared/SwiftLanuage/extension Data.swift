//
//  extension Data.swift
//  KanaKanjier
//
//  Created by β α on 2022/10/22.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

extension Data {
    /// Converts this data to an array of the given type.
    /// - Parameter:
    ///   - type: The type to convert this data to.
    /// - Returns: An array of the given type.
    func toArray<T>(of type: T.Type) -> [T] {
        self.withUnsafeBytes {pointer -> [T] in
            Array(
                UnsafeBufferPointer(
                    start: pointer.baseAddress!.assumingMemoryBound(to: type),
                    count: pointer.count / MemoryLayout<T>.size
                )
            )
        }
    }
}
