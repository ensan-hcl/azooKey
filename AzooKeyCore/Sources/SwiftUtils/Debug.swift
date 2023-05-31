//
//  Debug.swift
//
//
//  Created by ensan on 2023/04/30.
//

import Foundation

/// Prints the given items to the standard output if the build setting "DEBUG" is set.
/// - Parameter:
///   - items: The items to print.
/// - Note: This function is always preferred over `print` in the codebase.
@_disfavoredOverload
@inlinable public func debug(_ items: Any...) {
    #if DEBUG
    var result = ""
    for value in items {
        if result.isEmpty {
            result.append("\(value)")
        } else {
            result.append(" ")
            result.append("\(value)")
        }
    }
    print(result)
    #endif
}

@inlinable public func debug(_ item1: @autoclosure () -> Any) {
    #if DEBUG
    print(item1())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any, _ item6: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5(), item6())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any, _ item6: @autoclosure () -> Any, _ item7: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5(), item6(), item7())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any, _ item6: @autoclosure () -> Any, _ item7: @autoclosure () -> Any, _ item8: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5(), item6(), item7(), item8())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any, _ item6: @autoclosure () -> Any, _ item7: @autoclosure () -> Any, _ item8: @autoclosure () -> Any, _ item9: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5(), item6(), item7(), item8(), item9())
    #endif
}
@inlinable public func debug(_ item1: @autoclosure () -> Any, _ item2: @autoclosure () -> Any, _ item3: @autoclosure () -> Any, _ item4: @autoclosure () -> Any, _ item5: @autoclosure () -> Any, _ item6: @autoclosure () -> Any, _ item7: @autoclosure () -> Any, _ item8: @autoclosure () -> Any, _ item9: @autoclosure () -> Any, _ item10: @autoclosure () -> Any) {
    #if DEBUG
    print(item1(), item2(), item3(), item4(), item5(), item6(), item7(), item8(), item9(), item10())
    #endif
}
