//
//  BlackBoxTestCase.swift
//  
//
//  Created by Aleksey Berezka on 20.12.2022.
//

import XCTest
@testable import BlackBox

class BlackBoxTestCase: XCTestCase {
    let timeout: TimeInterval = 0.1
    var logger: (BBLoggerProtocol & TestableLoggerProtocol)!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        BlackBox.instance = .init(loggers: [])
    }
    
    override func tearDownWithError() throws {
        logger = nil
        try super.tearDownWithError()
    }
    
    func waitForMessage(
        isInverted: Bool = false,
        from code: () -> ()
    ) {
        let expectation = expectation(description: "Log received")
        expectation.isInverted = isInverted
        logger.messageExpectation = expectation
        
        code()
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func waitForError(
        isInverted: Bool = false,
        from code: () -> ()
    ) {
        let expectation = expectation(description: "Log received")
        expectation.isInverted = isInverted
        logger.errorExpectation = expectation
        
        code()
        
        wait(for: [expectation], timeout: timeout)
    }
}

protocol TestableLoggerProtocol {
    var messageExpectation: XCTestExpectation? { get set }
    var errorExpectation: XCTestExpectation? { get set }
}
