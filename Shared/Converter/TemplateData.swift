//
//  TemplateLiteral.swift
//  azooKey
//
//  Created by ensan on 2020/12/20.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation

struct TemplateData: Codable {
    var name: String
    var literal: TemplateLiteralProtocol
    var type: TemplateLiteralType

    private enum CodingKeys: String, CodingKey {
        case template
        case name
    }

    init(template: String, name: String) {
        self.name = name
        if template.dropFirst().hasPrefix("date") {
            self.type = .date
        } else if template.dropFirst().hasPrefix("random") {
            self.type = .random
        } else {
            debug("不明", template, name)
            self.type = .date
            self.literal = DateTemplateLiteral.example
            return
        }
        switch self.type {
        case .date:
            self.literal = DateTemplateLiteral.import(from: template)
        case .random:
            self.literal = RandomTemplateLiteral.import(from: template)
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let template = try values.decode(String.self, forKey: .template)
        let name = try values.decode(String.self, forKey: .name)
        self.init(template: template, name: name)
    }

    var previewString: String {
        literal.previewString()
    }

    func encode(to encoder: Encoder) throws {
        // containerはvarにしておく
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.literal.export(), forKey: .template)
        try container.encode(name, forKey: .name)
    }

    static let dataFileName = "user_templates.json"

    static func save(_ data: [TemplateData]) {
        if let json = try? JSONEncoder().encode(data) {
            guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(TemplateData.dataFileName) else {
                return
            }
            do {
                try json.write(to: url)
            } catch {
                debug("TemplateData.save", error)
            }
        }
    }

    static func load() -> [TemplateData] {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(Self.dataFileName)
            let json = try Data(contentsOf: url)
            let saveData = try JSONDecoder().decode([TemplateData].self, from: json)
            return saveData
        } catch {
            debug("TemplateData.load", error)
            return [
                TemplateData(template: "<random type=\"int\" value=\"1,6\">", name: "サイコロ"),
                TemplateData(template: "<random type=\"double\" value=\"0,1\">", name: "乱数"),
                TemplateData(template: "<random type=\"string\" value=\"大吉,吉,凶\">", name: "おみくじ"),
                TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "今日"),
                TemplateData(template: "<date format=\"yyyy年MM月dd日\" type=\"western\" language=\"ja_JP\" delta=\"1\" deltaunit=\"86400\">", name: "明日"),
                TemplateData(template: "<date format=\"Gy年MM月dd日\" type=\"japanese\" language=\"ja_JP\" delta=\"0\" deltaunit=\"1\">", name: "和暦")
            ]
        }
    }
}

protocol TemplateLiteralProtocol {
    func export() -> String

    func previewString() -> String
}

enum TemplateLiteralType {
    case date
    case random
}

extension TemplateLiteralProtocol {
    static func parse(splited: [some StringProtocol], key: String) -> some StringProtocol {
        let result = (splited.first {$0.hasPrefix(key + "=\"")} ?? "").dropFirst(key.count + 2).dropLast(1)
        if result.hasSuffix("\"") {
            return result.dropLast(1)
        }
        return result
    }
}

struct DateTemplateLiteral: TemplateLiteralProtocol, Equatable {
    static let example = DateTemplateLiteral(format: "yyyy年MM月dd日(EEE) a hh:mm:ss", type: .western, language: .japanese, delta: "0", deltaUnit: 1)
    var format: String
    var type: CalendarType
    var language: Language
    var delta: String
    var deltaUnit: Int

    enum CalendarType: String {
        case western
        case japanese

        var identifier: Calendar.Identifier {
            switch self {
            case .western:
                return .gregorian
            case .japanese:
                return .japanese
            }
        }
    }

    enum Language: String {
        case english = "en_US"
        case japanese = "ja_JP"

        var identifier: String {
            self.rawValue
        }
    }

    func previewString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: self.language.identifier)
        formatter.calendar = Calendar(identifier: self.type.identifier)
        formatter.dateFormat = format
        return formatter.string(from: Date().advanced(by: Double((Int(delta) ?? 0) * deltaUnit)))
    }

    static func `import`(from string: String, escaped: Bool = false) -> DateTemplateLiteral {
        let splited = string.split(separator: " ")
        let format = parse(splited: splited, key: "format")
        let type = parse(splited: splited, key: "type")
        let language = parse(splited: splited, key: "language")
        let delta = parse(splited: splited, key: "delta")
        let deltaUnit = parse(splited: splited, key: "deltaunit")
        return DateTemplateLiteral(
            format: format.unescaped(),
            type: CalendarType(rawValue: String(type))!,
            language: Language(rawValue: String(language))!,
            delta: String(delta),
            deltaUnit: Int(deltaUnit) ?? 0
        )
    }

    func export() -> String {
        """
        <date format="\(format.escaped())" type="\(type.rawValue)" language="\(language.identifier)" delta="\(delta)" deltaunit="\(deltaUnit)">
        """
    }
}

struct RandomTemplateLiteral: TemplateLiteralProtocol, Equatable {
    static func == (lhs: RandomTemplateLiteral, rhs: RandomTemplateLiteral) -> Bool {
        lhs.value == rhs.value
    }

    enum ValueType: String {
        case int
        case double
        case string
    }
    enum Value: Equatable {
        case int(from: Int, to: Int)
        case double(from: Double, to: Double)
        case string([String])

        var type: ValueType {
            switch self {
            case .int(from: _, to: _):
                return .int
            case .double(from: _, to: _):
                return .double
            case .string:
                return .string
            }
        }

        var string: String {
            switch self {
            case let .int(from: left, to: right):
                return "\(left),\(right)"
            case let .double(from: left, to: right):
                return "\(left),\(right)"
            case let .string(strings):
                return strings.map {$0.escaped()}.joined(separator: ",")
            }
        }
    }
    var value: Value

    func previewString() -> String {
        switch value {
        case let .int(from: left, to: right):
            return "\(Int.random(in: left...right))"
        case let .double(from: left, to: right):
            return "\(Double.random(in: left...right))"
        case let .string(strings):
            return strings.randomElement() ?? "データ無し"
        }
    }

    static func `import`(from string: String, escaped: Bool = false) -> RandomTemplateLiteral {
        let splited = string.split(separator: " ")
        let type = parse(splited: splited, key: "type")
        let valueString = parse(splited: splited, key: "value").unescaped()

        let valueType = ValueType(rawValue: String(type))!
        let value: Value
        switch valueType {
        case .int:
            let splited = valueString.split(separator: ",")
            value = .int(from: Int(splited[0]) ?? 0, to: Int(splited[1]) ?? 0)
        case .double:
            let splited = valueString.split(separator: ",")
            value = .double(from: Double(splited[0]) ?? .nan, to: Double(splited[1]) ?? .nan)
        case .string:
            value = .string(valueString.components(separatedBy: ","))
        }
        return RandomTemplateLiteral(value: value)
    }

    func export() -> String {
        """
        <random type="\(value.type.rawValue)" value="\(value.string.escaped())">
        """
    }

}
