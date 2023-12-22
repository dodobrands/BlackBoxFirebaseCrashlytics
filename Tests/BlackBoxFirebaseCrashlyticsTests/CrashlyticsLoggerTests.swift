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
    
    private func createLogger(
        messageLevels: [BBLogLevel] = .allCases, 
        errorLevels: [BBLogLevel] = .allCases,
        logFormat: BBLogFormat = BBLogFormat()
    ) {
        crashlyticsLogger = .init(
            messagesLogLevels: messageLevels,
            errorsLogLevels: errorLevels,
            logFormat: logFormat
        )
        
        BlackBox.instance = .init(loggers: [crashlyticsLogger])
        
        logger = crashlyticsLogger
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_genericEvent_message() {
        BlackBox.log("Hello there")
        
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:42
test_genericEvent_message()
"""
        XCTAssertEqual(crashlyticsLogger.loggedMessage, expectedResult)
    }
    
    func test_genericEvent_userInfo() {
        BlackBox.log("Hello there", userInfo: ["response": "General Kenobi"])
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:56
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
        BlackBox.log("Hello there", userInfo: ["response": Response(value: "General Kenobi")])
        
        let expectedResult = """
Hello there

[Source]
CrashlyticsLoggerTests:77
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
            BlackBox.log("Hello There", level: level)
        }

        XCTAssertNil(crashlyticsLogger.loggedMessage)
    }
    
    enum Error: Swift.Error {
        case someError
    }
    
    func test_errorEvent_invalidLevels() {
        
        createLogger(messageLevels: [.debug], errorLevels: [.debug])

        let logLevels: [BBLogLevel] = [.debug, .info, .warning]

        logLevels.forEach { level in
            BlackBox.log(Error.someError)
        }

        XCTAssertNil(crashlyticsLogger.loggedError)
    }

    func test_genericEvent_validLevel() {
        createLogger(messageLevels: [.error], errorLevels: [.error])

        BlackBox.log("Hello There", level: .error)
        XCTAssertNotNil(crashlyticsLogger.loggedMessage)
    }
    
    func test_errorEvent_validLevel() {
        createLogger(messageLevels: [.error], errorLevels: [.error])
        
        BlackBox.log(Error.someError)
        XCTAssertNotNil(crashlyticsLogger.loggedError)
    }

    func test_genericEvent_warningLevel_showIconIfEnabledInFormat() {
        createLogger(logFormat: BBLogFormat(levelsWithIcons: [.warning]))
        
        BlackBox.log("Message", level: .warning)
        XCTAssertEqual(crashlyticsLogger.loggedMessage, """
⚠️ Message

[Source]
CrashlyticsLoggerTests:138
test_genericEvent_warningLevel_showIconIfEnabledInFormat()
"""
        )
    }
    
    func test_genericEvent_inlineSource() {
        createLogger(logFormat: BBLogFormat(sourceSectionInline: true))
        
        BlackBox.log("Message", level: .warning)
        XCTAssertEqual(crashlyticsLogger.loggedMessage, """
Message

[Source] CrashlyticsLoggerTests:152 test_genericEvent_inlineSource()
"""
        )
    }

    func test_startEvent() {
        let _ = BlackBox.logStart("Process")
        XCTAssertEqual(crashlyticsLogger.loggedMessage, """
Start: Process

[Source]
CrashlyticsLoggerTests:162
test_startEvent()
""")
    }

    func test_endEvent() throws {
        BlackBox.logEnd(BlackBox.StartEvent("Process"))
        
        let message = try XCTUnwrap(crashlyticsLogger.loggedMessage)
        
        let prefix = "End: Process, duration"
        let suffix = """
[Source]
CrashlyticsLoggerTests:173
test_endEvent()
"""
        
        XCTAssertTrue(message.hasPrefix(prefix))
        XCTAssertTrue(message.hasSuffix(suffix))
    }
}

class CrashlyticsLoggerMock: CrashlyticsLogger {
    var loggedMessage: String?
    override func logMessage(_ message: String) {
        loggedMessage = message
    }
    
    var loggedError: NSError?
    override func logError(_ error: NSError) {
        loggedError = error
    }
}
