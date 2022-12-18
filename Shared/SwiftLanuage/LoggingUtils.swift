//
//  LoggingUtils.swift
//  KanaKanjier
//
//  Created by β α on 2022/12/18.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

@inlinable func debug(_ items: Any...) {
    #if DEBUG
    print(items.map {"\($0)"}.joined(separator: " "))
    #endif
}
