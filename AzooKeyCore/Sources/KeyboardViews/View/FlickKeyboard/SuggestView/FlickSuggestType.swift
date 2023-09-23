//
//  FlickSuggestType.swift
//
//
//  Created by miwa on 2023/08/20.
//

import enum CustardKit.FlickDirection

public enum FlickSuggestType: Equatable, Hashable, Sendable {
    /// all suggest is shown
    case all
    /// suggest is only shown to the direction
    case flick(FlickDirection)
}
