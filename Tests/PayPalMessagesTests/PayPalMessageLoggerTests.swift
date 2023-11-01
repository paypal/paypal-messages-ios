import Foundation
@testable import PayPalMessages
import XCTest

// swiftlint:disable:next type_body_length
final class PayPalMessageLoggerTests: XCTestCase {

    let mockSender = LogSenderMock()
    let logger = Logger.get(for: "testclientid", in: .live)

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
        logger.sender = mockSender
    }

    func testMessageLoggerEvents() {
        let messageLogger = Logger.createMessageLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product,
            styleColor: .black,
            styleLogoType: .inline,
            styleTextAlign: .left
        )

        messageLogger.dynamicData = [
            "string_key": "hello",
            "boolean_key": true,
            "number_key": 50.5
        ]

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))
        messageLogger.addEvent(.messageClick(linkName: "linkName", linkSrc: "linkSrc"))

        logger.flushEvents()

        guard let data = mockSender.data,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }

        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
            "lib_version": "1.0.0",
            "integration_name": "Test_SDK",
            "integration_type": "NATIVE_IOS",
            "client_id": "testclientid",
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
        let modalLogger = Logger.createModalLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product
        )

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

        logger.flushEvents()

        guard let data = mockSender.data,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }
        
        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
            "lib_version": "1.0.0",
            "integration_name": "Test_SDK",
            "integration_type": "NATIVE_IOS",
            "client_id": "testclientid",
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
        let messageLogger = Logger.createMessageLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product,
            styleColor: .black,
            styleLogoType: .inline,
            styleTextAlign: .left
        )
        let modalLogger = Logger.createModalLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product
        )

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

        logger.flushEvents()

        guard let data = mockSender.data,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }
        
        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
            "lib_version": "1.0.0",
            "integration_name": "Test_SDK",
            "integration_type": "NATIVE_IOS",
            "client_id": "testclientid",
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
        let messageLogger = Logger.createMessageLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product,
            styleColor: .black,
            styleLogoType: .inline,
            styleTextAlign: .left
        )
        _ = Logger.createModalLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product
        )

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        logger.flushEvents()

        guard let data = mockSender.data,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }
        
        
        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
            "lib_version": "1.0.0",
            "integration_name": "Test_SDK",
            "integration_type": "NATIVE_IOS",
            "client_id": "testclientid",
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
        let messageLogger = Logger.createMessageLogger(
            environment: .live,
            clientID: "testclientid",
            offerType: .payLaterLongTerm,
            amount: 50.0,
            placement: .product,
            styleColor: .black,
            styleLogoType: .inline,
            styleTextAlign: .left
        )

        messageLogger.addEvent(.messageRender(renderDuration: 10, requestDuration: 15))

        logger.flushEvents()

        messageLogger.addEvent(.messageClick(linkName: "linkName", linkSrc: "linkSrc"))

        logger.flushEvents()

        guard let data = mockSender.data,
              let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("invalid JSON data")
        }
        
        let expectedPayload: [String: Any] = [
            "specversion": "1.0",
            "id": "123456789",
            "type": "com.paypal.credit.upstream-presentment.v1",
            "source": "urn:paypal:event-src:v1:ios:messages",
            "datacontenttype": "application/json",
            "dataschema": "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json",
            "time": "2023-11-01T11:12:05.791-0400",
            "data": [
            "lib_version": "1.0.0",
            "integration_name": "Test_SDK",
            "integration_type": "NATIVE_IOS",
            "client_id": "testclientid",
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

        mockSender.data = nil

        logger.flushEvents()

        XCTAssertNil(mockSender.data)
    }

    // MARK: - Helper assert functions

    private func assert(payload: [String: Any], equals expectedPayload: [String: Any]) {
        var data = payload
        var expected = expectedPayload
        print("test payload", data)
        
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
