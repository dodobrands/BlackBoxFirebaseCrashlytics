//
//  CrashlyticsLogger.swift
//  DodoPizza
//
//  Created by Алексей Берёзка on 27.02.2020.
//  Copyright © 2020 Dodo Pizza. All rights reserved.
//

import Foundation
import BlackBox
import FirebaseCrashlytics

final class CrashlyticsLogger: BBLoggerProtocol {
    private let messagesLogLevels: [BBLogLevel]
    private let errorsLogLevels: [BBLogLevel]
    
    public init(messagesLogLevels: [BBLogLevel],
                errorsLogLevels: [BBLogLevel]) {
        self.messagesLogLevels = messagesLogLevels
        self.errorsLogLevels = errorsLogLevels
    }
    
    func log(_ event: BlackBox.ErrorEvent) {
        if errorsLogLevels.contains(event.level) {
            Crashlytics.crashlytics().record(error: event.error)
        }
        
        log(event as BlackBox.GenericEvent)
    }

    func log(_ event: BlackBox.GenericEvent) {
        crashlyticsLog(event)
    }
    
    func logStart(_ event: BlackBox.StartEvent) {
        crashlyticsLog(event)
    }
    
    func logEnd(_ event: BlackBox.EndEvent) {
        crashlyticsLog(event)
    }
}

extension CrashlyticsLogger {
    private func crashlyticsLog(_ event: BlackBox.GenericEvent) {
        guard messagesLogLevels.contains(event.level) else {
            return
        }
        
        let formattedMessage = formattedMessage(from: event)
        
        Crashlytics.crashlytics().log(formattedMessage)
    }
    
    private func formattedMessage(from event: BlackBox.GenericEvent) -> String {
        let message: String
        switch event.level {
        case .debug, .info:
            message = event.message
        case .error, .warning:
            message = event.level.icon + " " + event.message
        }
        
        
        let prefix = """
"\(event.source.filename)
\(event.source.function) - Line \(event.source.line)
"""
        
        let messageWithoutUserInfo = [
            prefix,
            message
        ].joined(separator: "\n")

        
        guard let userInfo = event.userInfo else {
            return messageWithoutUserInfo
        }
        
        return messageWithoutUserInfo
        + "\n\n"
        + "[User Info]:"
        + "\n"
        + userInfo.crashlyticsLogDescription
    }
}

extension CustomDebugStringConvertible {
    var crashlyticsLogDescription: String {
        if let json = self as? [String: Any] {
            return json.crashlyticsLogDescription
        }
        
        return String(describing: self)
    }
}

extension Dictionary where Key == String, Value == Any {
    var crashlyticsLogDescription: String {
        guard JSONSerialization.isValidJSONObject(self),
              let jsonData = try? JSONSerialization.data(withJSONObject: self,
                                                         options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else { return String(describing: self) }
        
        return jsonString
    }
}
