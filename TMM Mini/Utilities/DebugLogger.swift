//
//  DebugLogger.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation

struct DebugLogger {
    private static let logPath = "/Users/mustafa/Personal/TMM Mini/.cursor/debug.log"
    private static let sessionId = "debug-session-\(UUID().uuidString.prefix(8))"
    
    static func log(
        location: String,
        message: String,
        data: [String: Any] = [:],
        hypothesisId: String? = nil,
        runId: String = "run1"
    ) {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let logEntry: [String: Any] = [
            "id": "log_\(timestamp)_\(UUID().uuidString.prefix(8))",
            "timestamp": timestamp,
            "location": location,
            "message": message,
            "data": data,
            "sessionId": sessionId,
            "runId": runId,
            "hypothesisId": hypothesisId ?? ""
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: logEntry),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        // Also print to console for immediate visibility
        print("DEBUG [\(location)]: \(message) | Data: \(data) | Hypothesis: \(hypothesisId ?? "none")")
        
        // Write to file (may fail in iOS sandbox, but try anyway)
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write((jsonString + "\n").data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            // File doesn't exist, create it
            try? jsonString.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
}

