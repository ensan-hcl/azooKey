//
//  ArrayBuilder.swift
//  azooKey
//
//  Created by ensan on 2020/12/25.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

@resultBuilder
struct ArrayBuilder {
    public static func buildBlock<T>(_ values: T...) -> [T] {
        values
    }
}
