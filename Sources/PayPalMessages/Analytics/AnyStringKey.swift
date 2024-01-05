struct AnyStringKey: CodingKey, ExpressibleByStringLiteral {

    var stringValue: String
    var intValue: Int?

    init(stringValue: String) { self.stringValue = stringValue }
    init(_ stringValue: String) { self.init(stringValue: stringValue) }
    init?(intValue: Int) { nil }
    init(stringLiteral value: String) { self.init(value) }
}
