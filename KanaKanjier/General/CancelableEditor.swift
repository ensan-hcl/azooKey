//
//  CancelableEditor.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/21.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

protocol CancelableEditor: View {
    associatedtype EditTarget
    var base: EditTarget { get }
    func cancel()
}
