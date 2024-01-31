import Foundation
@testable import PayPalMessages
import XCTest

// swiftlint:disable:next type_body_length
final class PayPalMessageLoggerTests: XCTestCase {

    let mockSender = LogSenderMock()
    let message = PayPalMessageView(
        config: .init(
            data: .init(
                clientID: "testloggerclientid",
                environment: .live,
                amount: 50.0,
                placement: .product,
                offerType: .payLaterLongTerm
            ),
            style: .init(
                logoType: .inline,
                color: .black,
                textAlignment: .left
            )
        ),
        requester: PayPalMessageRequestMock(scenario: .success),
        merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
    )
    let modal = PayPalMessageModal(
        config: .init(
            data: .init(
                clientID: "testloggerclientid",
                environment: .live,
                amount: 50.0,
                placement: .product,
                offerType: .payLaterLongTerm
            )
        )
    )

    override func setUp() {
        super.setUp()

        BuildInfo.version = "1.0.0"

        PayPalMessageConfig.setGlobalAnalytics(
            integrationName: "Test_SDK",
            integrationVersion: "0.1.0",
            deviceID: "987654321",
            sessionID: "123456789"
        )

        // Inject mock sender to intercept log requests
        AnalyticsService.shared.sender = mockSender
        AnalyticsService.shared.loggers = []
    }

    func testMessageLoggerEvents() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))

        messageLogger.dynamicData = [
            "string_key": "hello",
            "boolean_key": true,
            "number_key": 50.5
        ]

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))
        messageLogger.addEvent(.messageClick(linkName: "linkName", linkSrc: "linkSrc"))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid",
                "merchant_profile_hash": "TEST_HASH",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "message",
                        "number_key": 50.5,
                        "string_key": "hello",
                        "boolean_key": true,
                        "style_logo_type": "inline",
                        "style_color": "black",
                        "style_text_align": "left",
                        "component_events": [
                            [
                                "event_type": "message_rendered",
                                "render_duration": 10,
                                "request_duration": 15
                            ],
                            [
                                "event_type": "message_clicked",
                                "page_view_link_name": "linkName",
                                "page_view_link_source": "linkSrc"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)
    }

    func testModalLoggerEvents() {
        let modalLogger = AnalyticsLogger(.modal(Weak(modal)))

        modalLogger.dynamicData = [
            "string_key": "hello",
            "boolean_key": true,
            "number_key": 50.5
        ]

        modalLogger.addEvent(.dynamic(data: [
            "event_type": "modal_click",
            "some_key": "test"
        ]))
        modalLogger.addEvent(.dynamic(data: [
            "event_type": "modal_open",
            "other_key": 100
        ]))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "modal",
                        "number_key": 50.5,
                        "string_key": "hello",
                        "boolean_key": true,
                        "component_events": [
                            [
                                "event_type": "modal_click",
                                "some_key": "test"
                            ],
                            [
                                "event_type": "modal_open",
                                "other_key": 100
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)
    }

    // swiftlint:disable:next function_body_length
    func testMultipleComponentEvents() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))
        let modalLogger = AnalyticsLogger(.modal(Weak(modal)))

        messageLogger.dynamicData = [
            "string_key": "hello"
        ]
        modalLogger.dynamicData = [
            "string_key": "world"
        ]

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))
        modalLogger.addEvent(.dynamic(data: [
            "event_type": "modal_click",
            "some_key": "test"
        ]))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid",
                "merchant_profile_hash": "TEST_HASH",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "message",
                        "string_key": "hello",
                        "style_logo_type": "inline",
                        "style_color": "black",
                        "style_text_align": "left",
                        "component_events": [
                            [
                                "event_type": "message_rendered",
                                "render_duration": 10,
                                "request_duration": 15
                            ]
                        ]
                    ],
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "modal",
                        "string_key": "world",
                        "component_events": [
                            [
                                "event_type": "modal_click",
                                "some_key": "test"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)
    }

    func testFiltersComponentsWithNoEvents() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))
        _ = AnalyticsLogger(.modal(Weak(modal)))

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid",
                "merchant_profile_hash": "TEST_HASH",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "message",
                        "style_logo_type": "inline",
                        "style_color": "black",
                        "style_text_align": "left",
                        "component_events": [
                            [
                                "event_type": "message_rendered",
                                "render_duration": 10,
                                "request_duration": 15
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)
    }

    func testClearsEventsAfterFlush() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        AnalyticsService.shared.flushEvents()

        messageLogger.addEvent(.messageClick(linkName: "linkName", linkSrc: "linkSrc"))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid",
                "merchant_profile_hash": "TEST_HASH",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 50,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "message",
                        "style_logo_type": "inline",
                        "style_color": "black",
                        "style_text_align": "left",
                        "component_events": [
                            [
                                "event_type": "message_clicked",
                                "page_view_link_name": "linkName",
                                "page_view_link_source": "linkSrc"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)

        mockSender.reset()

        AnalyticsService.shared.flushEvents()

        XCTAssertNil(mockSender.calls.last)
    }

    func testUpdatesWhenMessagePropertiesChange() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        AnalyticsService.shared.flushEvents()

        message.amount = 100.0
        message.clientID = "testloggerclientid2"

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        AnalyticsService.shared.flushEvents()

        guard let data = mockSender.calls.last,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            // swiftlint:disable:next line_length
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
                "lib_version": "1.0.0",
                "integration_name": "Test_SDK",
                "integration_type": "NATIVE_IOS",
                "client_id": "testloggerclientid2",
                "merchant_profile_hash": "TEST_HASH",
                "integration_version": "0.1.0",
                "device_id": "987654321",
                "session_id": "123456789",
                "components": [
                    [
                        "amount": 100,
                        "offer_type": "PAY_LATER_LONG_TERM",
                        "placement": "product",
                        "type": "message",
                        "style_logo_type": "inline",
                        "style_color": "black",
                        "style_text_align": "left",
                        "component_events": [
                            [
                                "event_type": "message_rendered",
                                "render_duration": 10,
                                "request_duration": 15
                            ]
                        ]
                    ]
                ]
            ]
        ]

        assert(payload: data, equals: expectedPayload)
    }

    func testSendsSeparatePayloadsForDifferentClientIDs() {
        let messageLogger = AnalyticsLogger(.message(Weak(message)))
        let modalLogger = AnalyticsLogger(.modal(Weak(modal)))

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))
        modalLogger.addEvent(.dynamic(data: [
            "event_type": "modal_click",
            "some_key": "test"
        ]))

        message.clientID = "testloggerclientid2"
        modal.clientID = "testloggerclientid3"

        AnalyticsService.shared.flushEvents()

        XCTAssert(mockSender.calls.count == 2)

        let data1 = mockSender.calls[0]
        let data2 = mockSender.calls[1]

        guard let data1 = try? JSONSerialization.jsonObject(with: data1) as? [String: Any],
              let data2 = try? JSONSerialization.jsonObject(with: data2) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let clientID1 = (data1["data"] as? [String: Any])?["client_id"] as? String
        let clientID2 = (data2["data"] as? [String: Any])?["client_id"] as? String

        XCTAssert(clientID1 != clientID2)
        XCTAssert(clientID1 == "testloggerclientid2" || clientID2 == "testloggerclientid2")
        XCTAssert(clientID1 == "testloggerclientid3" || clientID2 == "testloggerclientid3")
    }

    // MARK: - Helper assert functions

    private func assert(payload: [String: Any], equals expectedPayload: [String: Any]) {
        var data = payload
        var expected = expectedPayload

        // Extract logger data from CloudEvent
        guard var loggerData = data["data"] as? [String: Any] else {
            return XCTFail("missing logger data within CloudEvent")
        }

        // Extract components from logger data
        guard var components = loggerData["components"] as? [[String: Any]] else {
            return XCTFail("missing components")
        }

        // Ensure that the instance_id exists and then remove it since it generates a unique
        // value for each test run
        for (index, var value) in components.enumerated() {
            guard value["instance_id"] is String else {
                return XCTFail("invalid instance_id")
            }
            value.removeValue(forKey: "instance_id")
            components[index] = value
        }

        // Update the modified components back into loggerData
        loggerData["components"] = components

        // Update the modified loggerData back into the CloudEvent data
        data["data"] = loggerData

        // Ensure that the id exists and then remove it since it generates a unique value for each test run
        guard data["id"] is String else {
            return XCTFail("invalid id")
        }
        data.removeValue(forKey: "id")
        expected.removeValue(forKey: "id")

        // Ensure that the time exists and then remove it since it generates a unique value for each test run
        guard data["time"] is String else {
            return XCTFail("invalid time")
        }
        data.removeValue(forKey: "time")
        expected.removeValue(forKey: "time")

        let isEqual = NSDictionary(dictionary: data).isEqual(to: expected)

        if !isEqual,
           let payloadData = try? JSONSerialization.data(
            withJSONObject: data,
            options: .prettyPrinted
           ),
           let expectedData = try? JSONSerialization.data(
            withJSONObject: expected,
            options: .prettyPrinted
           ) {
            let payloadString = String(decoding: payloadData, as: UTF8.self)
            let expectedString = String(decoding: expectedData, as: UTF8.self)

            print("Expected:\n\(expectedString)\n\nReceived:\n\(payloadString)")
        }

        XCTAssertTrue(isEqual)
    }
}
// swiftlint:disable:this file_length
