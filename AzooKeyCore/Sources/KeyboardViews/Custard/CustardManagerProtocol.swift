//
//  CustardManagerProtocol.swift
//
//
//  Created by ensan on 2023/07/22.
//

import CustardKit

public protocol CustardManagerProtocol {
    func custard(identifier: String) throws -> Custard
    func tabbar(identifier: Int) throws -> TabBarData
}
