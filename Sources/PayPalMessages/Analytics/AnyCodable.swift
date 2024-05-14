struct AnyCodable: Codable,
                   ExpressibleByNilLiteral,
                   ExpressibleByBooleanLiteral,
                   ExpressibleByIntegerLiteral,
                   ExpressibleByFloatLiteral,
                   ExpressibleByStringLiteral,
                   ExpressibleByStringInterpolation,
                   ExpressibleByArrayLiteral,
                   ExpressibleByDictionaryLiteral {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyDecodable value cannot be decoded"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is Void:
            try container.encodeNil()

        case let bool as Bool:
            try container.encode(bool)

        case let int as Int:
            try container.encode(int)

        case let double as Double:
            try container.encode(double)

        case let string as String:
            try container.encode(string)

        case let array as [Any?]:
            try container.encode(array.map { AnyCodable($0) })

        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })

        case let encodable as Encodable:
            try encodable.encode(to: encoder)

        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyCodable value cannot be encoded"
            )
            throw EncodingError.invalidValue(value, context)
        }
    }

    // MARK: - ExpressibleBy protocol initializers
    init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }
    init(booleanLiteral value: Bool) {
        self.init(value)
    }
    init(integerLiteral value: Int) {
        self.init(value)
    }
    init(floatLiteral value: Double) {
        self.init(value)
    }
    init(stringLiteral value: String) {
        self.init(value)
    }
    init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    init(dictionaryLiteral elements: (String, Any)...) {
        self.init(
            [String: Any](elements) { first, _ in first }
        )
    }
}
