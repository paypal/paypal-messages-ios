// NOTE: The values on this enum are meant to be managed by the CI or constants for the library.
// If any of the names are changed the CI should be updated as well.
//
// `version` is the canonical runtime version for the PayPalMessages library.
// Ensure your CI pipeline keeps this value in sync with the versions declared in
// `Package.swift` and `PayPalMessages.podspec` to avoid mismatches.
public enum BuildInfo {
    /// Library version
    public internal(set) static var version: String = "1.2.0"
    /// Message rendering environment
    public static let integrationType: String = "NATIVE_IOS"
    /// Default message content channel
    public static let channel: String = "UPSTREAM"
}
