//
//  CrashlyticsLogger.swift
//  DodoPizza
//
//  Created by Алексей Берёзка on 27.02.2020.
//  Copyright © 2020 Dodo Pizza. All rights reserved.
//

import Foundation
import DFoundation
import FirebaseCrashlytics

extension BlackBox {
    final class CrashlyticsLogger: BBLoggerProtocol {
        private let messagesLogLevels: [BBLogLevel]
        private let errorsLogLevels: [BBLogLevel]
        
        public init(messagesLogLevels: [BBLogLevel],
                    errorsLogLevels: [BBLogLevel]) {
            self.messagesLogLevels = messagesLogLevels
            self.errorsLogLevels = errorsLogLevels
        }
        
        func log(_ error: Error,
                 eventType: BBEventType,
                 eventId: UInt64?,
                 file: StaticString,
                 category: String?,
                 function: StaticString,
                 line: UInt) {
            if errorsLogLevels.contains(error.logLevel) {
                Crashlytics.crashlytics().record(error: error)
            }
            
            log(message(from: String(reflecting: error),
                        with: error.logLevel),
                userInfo: nil,
                logLevel: error.logLevel,
                eventType: eventType,
                eventId: eventId,
                file: file,
                category: category,
                function: function,
                line: line)
        }
        
        func log(_ message: String,
                 userInfo: CustomDebugStringConvertible?,
                 logLevel: BBLogLevel,
                 eventType: BBEventType,
                 eventId: UInt64?,
                 file: StaticString,
                 category: String?,
                 function: StaticString,
                 line: UInt) {
            guard messagesLogLevels.contains(logLevel) else {
                return
            }
            
            let messageWithUserInfo = messageWithUserInfo(message: message,
                                                          userInfo: userInfo)
            
            Crashlytics.crashlytics().log(messageWithUserInfo)
        }
        
        private func messageWithUserInfo(message: String,
                                         userInfo: CustomDebugStringConvertible?) -> String {
            guard let userInfo = userInfo else {
                return message
            }
            
            return message + "\n\n" + "[User Info]:" + "\n" + userInfo.crashlyticsLogDescription
        }
    }
}

extension BlackBox.CrashlyticsLogger {
    private func message(from message: String, with logLevel: BBLogLevel) -> String {
        switch logLevel {
        case .debug, .default, .info:
            return message
        case .error, .warning:
            return logLevel.icon + " " + message
        }
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
