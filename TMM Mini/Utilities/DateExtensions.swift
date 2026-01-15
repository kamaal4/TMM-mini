//
//  DateExtensions.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    static func datesForLast7Days() -> [Date] {
        let today = Date()
        return (0..<7).map { today.daysAgo(6 - $0) }
    }
    
    static func datesForPreviousWeek() -> [Date] {
        let today = Date()
        // Previous week: 7-13 days ago (older to newer)
        return Array((7..<14).map { today.daysAgo($0) }.reversed())
    }
    
    var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
    
    var weekdaySingle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: self)
    }
}

