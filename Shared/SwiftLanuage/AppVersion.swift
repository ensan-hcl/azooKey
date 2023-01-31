//
//  AppVersion.swift
//  azooKey
//
//  Created by ensan on 2022/07/02.
//  Copyright © 2022 ensan. All rights reserved.
//

import Foundation

/// AppVersion is a struct that represents a version of an app.
/// It is a wrapper of String that conforms to Codable, Equatable, Comparable, Hashable, LosslessStringConvertible, CustomStringConvertible.
/// It is initialized with a string that represents a version of an app.
/// The string must be in the format of "major.minor.patch".
/// The string must not contain any other characters than numbers and dots.
struct AppVersion: Codable, Equatable, Comparable, Hashable, LosslessStringConvertible, CustomStringConvertible {

    /// ParseError is an enum that represents an error that occurs when parsing a string to an AppVersion.
    private enum ParseError: Error {
        case nonIntegerValue
    }

    /// Initializes an AppVersion with a string that represents a version of an app.
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

    /// Compares two AppVersions.
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
