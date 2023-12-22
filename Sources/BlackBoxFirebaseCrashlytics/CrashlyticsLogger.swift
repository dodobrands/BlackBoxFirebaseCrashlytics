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

public class CrashlyticsLogger: BBLoggerProtocol {
    private let messagesLogLevels: [BBLogLevel]
    private let errorsLogLevels: [BBLogLevel]
    private let logFormat: BBLogFormat
    
    public init(messagesLogLevels: [BBLogLevel],
                errorsLogLevels: [BBLogLevel],
                logFormat: BBLogFormat = BBLogFormat()) {
        self.messagesLogLevels = messagesLogLevels
        self.errorsLogLevels = errorsLogLevels
        self.logFormat = logFormat
    }
    
    public func log(_ event: BlackBox.ErrorEvent) {
        logError(event)
        logMessage(event)
    }

    public func log(_ event: BlackBox.GenericEvent) {
        logMessage(event)
    }
    
    public func logStart(_ event: BlackBox.StartEvent) {
        logMessage(event)
    }
    
    public func logEnd(_ event: BlackBox.EndEvent) {
        logMessage(event)
    }
    
    private func logMessage(_ event: BlackBox.GenericEvent) {
        guard messagesLogLevels.contains(event.level) else { return }
        
        let formattedMessage = formattedMessage(from: event)
        
        logMessage(formattedMessage)
    }
    
    private func logError(_ event: BlackBox.ErrorEvent) {
        guard errorsLogLevels.contains(event.level) else { return }
        
        logError(event.error as NSError)
    }
    
    func logMessage(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func logError(_ error: NSError) {
        Crashlytics.crashlytics().record(error: error)
    }
}

extension CrashlyticsLogger {
    private func formattedMessage(from event: BlackBox.GenericEvent) -> String {
        let icon: String?
        if logFormat.showLevelIcon {
            switch event.level {
            case .debug, .info:
                icon = nil
            case .error, .warning:
                icon = event.level.icon
            }
        } else {
            icon = nil
        }

        
        let source = """
[Source]
\(event.source.filename):\(event.source.line)
\(event.source.function)
"""
        
        let messageWithFormattedDuration = event.messageWithFormattedDuration(using: logFormat.measurementFormatter)
        
        let message = [icon, messageWithFormattedDuration].compactMap { $0 }.joined(separator: " ")
        let messageWithoutUserInfo = [
            message,
            source
        ].joined(separator: "\n\n")

        
        guard let userInfo = event.userInfo else {
            return messageWithoutUserInfo
        }
        
        return messageWithoutUserInfo
        + "\n\n"
        + "[User Info]"
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

extension CrashlyticsLogger {
    struct LogData {
        
    }
}
