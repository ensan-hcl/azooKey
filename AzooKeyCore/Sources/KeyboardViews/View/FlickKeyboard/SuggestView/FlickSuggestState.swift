//
//  FlickSuggestState.swift
//  
//
//  Created by miwa on 2023/08/20.
//


struct FlickSuggestState: Equatable, Hashable, Sendable {
    /// 横：縦：サジェストタイプ
    var items: [Int: [Int: FlickSuggestType]] = [:]
}
