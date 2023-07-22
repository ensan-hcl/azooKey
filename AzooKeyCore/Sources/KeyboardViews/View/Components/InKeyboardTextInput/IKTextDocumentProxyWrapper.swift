//
//  IKTextDocumentProxyWrapper.swift
//  azooKey
//
//  Created by ensan on 2023/03/18.
//  Copyright © 2023 ensan. All rights reserved.
//

import Foundation
import UIKit

struct IKTextDocumentProxyWrapper: Equatable, Hashable {
    private var updateDate: Date = Date()
    var proxy: IKTextDocumentProxy? {
        didSet {
            updateDate = Date()
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.updateDate == rhs.updateDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(updateDate)
    }
}
