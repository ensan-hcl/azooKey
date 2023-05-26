//
//  KanaKanjiConverterResourceURL.swift
//  
//
//  Created by ensan on 2023/05/20.
//

import Foundation

public enum KanaKanjiConverterResourceURL {
    /// provide URL for resource
    public static var url: URL {
        return Bundle.module.resourceURL?.standardizedFileURL ?? Bundle.module.bundleURL
    }
}
