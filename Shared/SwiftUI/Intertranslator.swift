//
//  Intertranslator.swift
//  azooKey
//
//  Created by ensan on 2021/04/28.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
public protocol Intertranslator {
    associatedtype First
    associatedtype Second

    static func convert(_ first: First) -> Second
    static func convert(_ second: Second) -> First
}
