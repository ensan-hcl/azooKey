//
//  CancelableEditor.swift
//  MainApp
//
//  Created by ensan on 2021/04/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import SwiftUI

protocol CancelableEditor: View {
    associatedtype EditTarget
    var base: EditTarget { get }
    func cancel()
}
