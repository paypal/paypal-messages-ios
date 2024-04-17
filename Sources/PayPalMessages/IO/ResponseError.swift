import Foundation

struct ResponseError: Decodable {

    let paypalDebugID: String
    let issue: String?
    let description: String?

    init(paypalDebugID: String, issue: String?, description: String?) {
        self.paypalDebugID = paypalDebugID
        self.issue = issue
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case paypalDebugID = "debug_id"
        case details
    }

    enum DetailsKeys: CodingKey {
        case issue
        case description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        paypalDebugID = try container.decode(String.self, forKey: .paypalDebugID)

        guard var detailsContainer = try? container.nestedUnkeyedContainer(forKey: .details) else {
            issue = nil
            description = nil

            return
        }

        let detailContainer = try detailsContainer.nestedContainer(keyedBy: DetailsKeys.self)

        issue = try detailContainer.decode(String.self, forKey: .issue)
        description = try detailContainer.decode(String.self, forKey: .description)
    }
}
