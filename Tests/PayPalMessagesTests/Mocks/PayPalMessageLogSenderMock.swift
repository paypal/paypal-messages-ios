@testable import PayPalMessages
import Foundation

class LogSenderMock: LogSendable {

    var calls: [Data] = []

    func send(_ data: Data, to environement: Environment) {
        self.calls.append(data)
    }

    func reset() {
        self.calls = []
    }
}
