//
//  ResultViewItemData.swift
//  azooKey
//
//  Created by ensan on 2023/03/24.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation

public protocol ResultViewItemData {
    var text: String {get}
    var inputable: Bool {get}
    #if DEBUG
    func getDebugInformation() -> String
    #endif
}

public struct ResultModelVariableSection {
    private(set) var results: [ResultData] = []
    private(set) var predictionResults: [ResultData] = []
    private(set) var searchResults: [ResultData] = []
    private(set) var updateResult: Bool = false

    public mutating func setResults(_ results: [any ResultViewItemData]) {
        self.results = results.indices.map {ResultData(id: $0, candidate: results[$0])}
        self.predictionResults = []
        self.updateResult.toggle()
    }
    public mutating func setSearchResults(_ results: [any ResultViewItemData]) {
        self.searchResults = results.indices.map {ResultData(id: $0, candidate: results[$0])}
    }
    public mutating func setPredictionResults(_ results: [any ResultViewItemData]) {
        self.predictionResults = results.indices.map {ResultData(id: $0, candidate: results[$0])}
        self.updateResult.toggle()
    }
}

struct ResultData: Identifiable {
    var id: Int
    var candidate: any ResultViewItemData
}
