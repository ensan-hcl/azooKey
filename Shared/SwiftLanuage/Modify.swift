//
//  Modify.swift
//  KanaKanjier
//
//  Created by β α on 2022/10/10.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

/// Modifies the given value and returns the result.
/// - Parameters:
///   - value: The value to modify.
///   - process: The process to modify the value.
/// - Note: This function should be used when specific subscript setter is called for multiple times.
func withMutableValue<T>(_ value: inout T, process: (inout T) -> Void) {
    process(&value)
}
