import Foundation

struct MerchantProfileData: Codable {

    // MARK: - Attributes

    let hash: String
    let ttlHard: Date
    let ttlSoft: Date
    let disabled: Bool

    // MARK: - Init

    init(
        hash: String,
        ttlHard: Date,
        ttlSoft: Date,
        disabled: Bool
    ) {
        self.hash = hash
        self.ttlHard = ttlHard
        self.ttlSoft = ttlSoft
        self.disabled = disabled
    }


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // ttlHard and ttlSoft can be either a Date String (when decoding from the local cache)
        // or Int in seconds when being decoded from the merchant profile endpoint response.
        do {
            let ttlHardSeconds = try container.decode(Int.self, forKey: .ttlHard)
            ttlHard = Date().addingTimeInterval(TimeInterval(ttlHardSeconds))
        } catch {
            ttlHard = try container.decode(Date.self, forKey: .ttlHard)
        }

        do {
            let ttlSoftSeconds = try container.decode(Int.self, forKey: .ttlSoft)
            ttlSoft = Date().addingTimeInterval(TimeInterval(ttlSoftSeconds))
        } catch {
            ttlSoft = try container.decode(Date.self, forKey: .ttlSoft)
        }

        disabled = try container.decode(Bool.self, forKey: .disabled)

        let merchantProfileContainer = try container.nestedContainer(
            keyedBy: MerchantProfileKeys.self,
            forKey: .merchantProfile
        )

        hash = try merchantProfileContainer.decode(String.self, forKey: .hash)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var merchantProfile = container.nestedContainer(
            keyedBy: MerchantProfileKeys.self,
            forKey: .merchantProfile
        )
        try merchantProfile.encode(hash, forKey: .hash)

        try container.encode(ttlHard, forKey: .ttlHard)
        try container.encode(ttlSoft, forKey: .ttlSoft)
        try container.encode(disabled, forKey: .disabled)
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case merchantProfile = "merchant_profile"
        case ttlHard = "ttl_hard"
        case ttlSoft = "ttl_soft"
        case disabled = "cache_flow_disabled"
    }

    enum MerchantProfileKeys: String, CodingKey {
        case hash
    }
}
