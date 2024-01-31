import Foundation

extension UserDefaults {

    enum Key: String {
        case merchantProfileData = "paypal.messages.merchantProfileHash"
    }

    // holds the data for a merchant profile, of type PayPalMessageMerchantData
    static func getMerchantProfileData(forClientID clientID: String, merchantID: String?) -> Data? {
        return standard.data(forKey: "\(Key.merchantProfileData.rawValue).\(clientID).\(merchantID ?? "default")")
    }

    static func setMerchantProfileData(_ value: Data?, forClientID clientID: String, merchantID: String?) {
        standard.set(value, forKey: "\(Key.merchantProfileData.rawValue).\(clientID).\(merchantID ?? "default")")
    }
}
