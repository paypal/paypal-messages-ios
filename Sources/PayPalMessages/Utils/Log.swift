import Foundation

enum LogLevel: Int {
    case debug
    case info
    case warn
    case error
}

func log(_ level: LogLevel, _ message: String, with data: Data? = nil, for environment: Environment) {
    if level == .debug && environment.isProduction {
        return
    }

    var message = message

    if let data {
        guard let jsonAny = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
              let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonAny,
                options: .prettyPrinted
              ) else { return }
        message += "\n"
        message += String(decoding: jsonData, as: UTF8.self)
    }

    print(message)
}
