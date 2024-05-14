import Foundation

class AnalyticsService {

    static let shared = AnalyticsService()

    // Integration Details
    let timerInterval: Double = 5
    var timer: Timer?
    var sender: LogSendable = LogSender()
    var loggers: [AnalyticsLogger] = []


    private init() {
        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: true
        ) { _ in
            self.flushEvents()
        }
    }

    deinit {
        timer?.invalidate()
        flushEvents()
    }

    func addLogger(_ logger: AnalyticsLogger) {
        loggers.append(logger)
    }

    func clearEvents() {
        for logger in loggers {
            logger.clearEvents()
        }
    }

    func flushEvents() {
        let cloudEvents = CloudEvent.create(from: loggers)

        guard !cloudEvents.isEmpty else { return }

        for cloudEvent in cloudEvents {
            if let cloudEventData = try? JSONEncoder().encode(cloudEvent) {
                sender.send(cloudEventData, to: cloudEvent.environment)
            }
        }

        clearEvents()
    }
}

protocol LogSendable {
    func send(_ data: Data, to environment: Environment)
}

class LogSender: LogSendable {

    func send(_ data: Data, to environment: Environment) {
        guard let url = environment.url(.log) else { return }
        let headers: [HTTPHeader: String] = [
            .acceptLanguage: "en_US",
            .accept: "application/json",
            .contentType: "application/cloudevents+json"
        ]

        log(.debug, "log_payload", with: data, for: environment)

        fetch(url, method: .post, headers: headers, body: data, session: environment.urlSession) { _, _, _ in }
    }
    deinit {}
}
