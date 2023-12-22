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
    var logger: BBLoggerProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        BlackBox.instance = .init(loggers: [])
    }
    
    override func tearDownWithError() throws {
        logger = nil
        try super.tearDownWithError()
    }
}
