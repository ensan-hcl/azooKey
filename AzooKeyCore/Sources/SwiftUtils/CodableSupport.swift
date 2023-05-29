//
//  CodableSupport.swift
//  azooKey
//
//  Created by ensan on 2021/03/17.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation

public extension Encodable {
    /// Encodes this value into the given container.
    /// - Parameters:
    ///   - container: The container to encode this value into.
    func containerEncode<CodingKeys: CodingKey>(container: inout KeyedEncodingContainer<CodingKeys>, key: CodingKeys) throws {
        try container.encode(self, forKey: key)
    }
}
