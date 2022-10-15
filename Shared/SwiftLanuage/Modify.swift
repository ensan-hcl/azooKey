//
//  Modify.swift
//  KanaKanjier
//
//  Created by β α on 2022/10/10.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

func withMutableValue<T>(_ value: inout T, process: (inout T) -> ()) {
    process(&value)
}
