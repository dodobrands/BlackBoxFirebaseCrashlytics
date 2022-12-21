//
//  CrashlyticsLogger.swift
//  BlackBoxFirebaseTests
//
//  Created by Алексей Берёзка on 30.03.2021.
//

import XCTest
import BlackBox
@testable import BlackBoxFirebaseCrashlytics

class CrashlyticsLoggerTests: BlackBoxTestCase {
    var crashlyticsLogger: CrashlyticsLoggerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        createLogger(messageLevels: .allCases, errorLevels: .allCases)
    }
    
    private func createLogger(messageLevels: [BBLogLevel], errorLevels: [BBLogLevel]) {
        crashlyticsLogger = .init(messagesLogLevels: messageLevels, errorsLogLevels: errorLevels)
        BlackBox.instance = .init(loggers: [crashlyticsLogger])
        
        logger = crashlyticsLogger
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_genericEvent_message() {
        waitForMessage { BlackBox.log("Hello there") }
        
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:33
test_genericEvent_message()
"""
        XCTAssertEqual(crashlyticsLogger.loggedMessage, expectedResult)
    }
    
    func test_genericEvent_userInfo() {
        waitForMessage { BlackBox.log("Hello there", userInfo: ["response": "General Kenobi"]) }
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:47
test_genericEvent_userInfo()

[User Info]
{
  "response" : "General Kenobi"
}
"""
        XCTAssertEqual(crashlyticsLogger.loggedMessage, expectedResult)
    }
    
    struct Response {
        let value: String
    }
    func test_genericEvent_userInfo_nonCodable() {
        waitForMessage { BlackBox.log("Hello there", userInfo: ["response": Response(value: "General Kenobi")]) }
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:68
test_genericEvent_userInfo_nonCodable()

[User Info]
["response": BlackBoxFirebaseCrashlyticsTests.CrashlyticsLoggerTests.Response(value: "General Kenobi")]
"""
        XCTAssertEqual(crashlyticsLogger.loggedMessage, expectedResult)
    }
    
    func test_genericEvent_invalidLevels() {
        createLogger(messageLevels: [.error], errorLevels: [.error])

        let logLevels: [BBLogLevel] = [.debug, .info, .warning]

        logLevels.forEach { level in
            waitForMessage(isInverted: true) { BlackBox.log("Hello There", level: level) }
        }

        XCTAssertNil(crashlyticsLogger.loggedMessage)
    }
    
    func test_errorEvent_invalidLevels() {
        enum Error: Swift.Error {
            case someError
        }
        createLogger(messageLevels: [.debug], errorLevels: [.debug])

        let logLevels: [BBLogLevel] = [.debug, .info, .warning]

        logLevels.forEach { level in
            waitForError(isInverted: true) { BlackBox.log(Error.someError) }
        }

        XCTAssertNil(crashlyticsLogger.loggedError)
    }

    func test_genericEvent_validLevel() {
        createLogger(messageLevels: [.error], errorLevels: [.error])

        waitForMessage { BlackBox.log("Hello There", level: .error) }
        XCTAssertNotNil(crashlyticsLogger.loggedMessage)
    }
    
    func test_errorEvent_validLevel() {
        enum Error: Swift.Error {
            case someError
        }
        
        createLogger(messageLevels: [.error], errorLevels: [.error])

        waitForError { BlackBox.log(Error.someError) }
        XCTAssertNotNil(crashlyticsLogger.loggedError)
    }


    func test_startEvent() {
        waitForMessage { let _ = BlackBox.logStart("Process") }
        XCTAssertEqual(crashlyticsLogger.loggedMessage, """
Start: Process

[Source]
CrashlyticsLoggerTests:130
test_startEvent()
""")
    }

    func test_endEvent() throws {
        waitForMessage { BlackBox.logEnd(BlackBox.StartEvent("Process")) }
        
        let message = try XCTUnwrap(crashlyticsLogger.loggedMessage)
        
        let prefix = "End: Process, duration"
        let suffix = """
[Source]
CrashlyticsLoggerTests:141
test_endEvent()
"""
        
        XCTAssertTrue(message.hasPrefix(prefix))
        XCTAssertTrue(message.hasSuffix(suffix))
    }
}

class CrashlyticsLoggerMock: CrashlyticsLogger, TestableLoggerProtocol {
    var messageExpectation: XCTestExpectation?
    var loggedMessage: String?
    override func logMessage(_ message: String) {
        loggedMessage = message
        messageExpectation?.fulfill()
    }
    
    var errorExpectation: XCTestExpectation?
    var loggedError: NSError?
    override func logError(_ error: NSError) {
        loggedError = error
        errorExpectation?.fulfill()
    }
}
