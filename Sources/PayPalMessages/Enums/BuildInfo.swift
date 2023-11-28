// NOTE: The values on this enum are meant to be managed by the CI or constants for the library.
// If any of the names are changed the CI should be updated as well.
public enum BuildInfo {
    /// Library version
    public internal(set) static var version: String = "1.0.0-prerelease.2"
    /// Message rendering environment
    public static let integrationType: String = "NATIVE_IOS"
}
