//
//  LoggingUtils.swift
//  KanaKanjier
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

/// Prints the given items to the standard output if the build setting "DEBUG" is set.
/// - Parameter:
///   - items: The items to print.
/// - Note: This function is always preferred over `print` in the codebase.
@inlinable func debug(_ items: Any...) {
    #if DEBUG
    print(items.map {"\($0)"}.joined(separator: " "))
    #endif
}
