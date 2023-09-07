import Foundation

/// Property wrapper that delegates get and set operations of a property to another location
@propertyWrapper
public struct AnyProxy<EnclosingType, Value> {

    public typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>

    private let keyPath: ValueKeyPath

    // Makes use of subscript to get access to the enclosing class instance
    // https://github.com/apple/swift-evolution/blob/main/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type
    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ValueKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> Value {
        get {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            return instance[keyPath: keyPath]
        }
        set {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            instance[keyPath: keyPath] = newValue
        }
    }

    @available(*, unavailable, message: "only works on instance properties of classes")
    public var wrappedValue: Value {
        get { fatalError("only works on instance properties of classes") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("only works on instance properties of classes") }
    }

    public init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }
}
