//
//  AppVersion.swift
//  KanaKanjier
//
//  Created by β α on 2022/07/02.
//  Copyright © 2022 DevEn3. All rights reserved.
//

import Foundation

struct AppVersion: Codable, Equatable, Comparable, Hashable, LosslessStringConvertible, CustomStringConvertible, Sendable {

    private enum ParseError: Error {
        case nonIntegerValue
    }
    init?(_ description: String) {
        if let versionSequence = try? description.split(separator: ".").map({ (value: Substring) throws -> Int in
            guard let value = Int(value) else { throw ParseError.nonIntegerValue }
            return value
        }) {
            if versionSequence.count < 1 {
                self.majorVersion = 0
            } else {
                self.majorVersion = versionSequence[0]
            }

            if versionSequence.count < 2 {
                self.minorVersion = 0
            } else {
                self.minorVersion = versionSequence[1]
            }

            if versionSequence.count < 3 {
                self.patchVersion = 0
            } else {
                self.patchVersion = versionSequence[2]
            }
        } else {
            return nil
        }
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        for (l, r) in zip([lhs.majorVersion, lhs.minorVersion, lhs.patchVersion], [rhs.majorVersion, rhs.minorVersion, rhs.patchVersion]) {
            if l == r {
                continue
            }
            return l < r
        }
        return false
    }
    var majorVersion: Int
    var minorVersion: Int
    var patchVersion: Int

    var description: String {
        "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}
