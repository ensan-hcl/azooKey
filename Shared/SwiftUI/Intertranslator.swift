//
//  Intertranslator.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/28.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
public protocol Intertranslator {
    associatedtype First
    associatedtype Second

    static func convert(_ first: First) -> Second
    static func convert(_ second: Second) -> First
}
