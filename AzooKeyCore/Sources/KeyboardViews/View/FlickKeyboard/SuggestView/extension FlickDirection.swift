//
//  extension FlickDirection.swift
//  
//
//  Created by miwa on 2023/08/20.
//

import enum CustardKit.FlickDirection

extension FlickDirection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left:
            return "左"
        case .top:
            return "上"
        case .right:
            return "右"
        case .bottom:
            return "下"
        }
    }
}
