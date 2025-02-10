//
//  DateFormatModel.swift
//  TripLog
//
//  Created by jae hoon lee on 2/5/25.
//

import Foundation

extension Formatter {
    
    // coreData에 있는 rateDate를 Date타입으로 변경
    static let rateDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    /// String -> Date타입으로 변경
    static func rateDateValue(_ date: String) -> Date? {
        return rateDateFormatter.date(from: date)
    }
    
    // 받아온 날짜 string 값
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    // 변화될 날짜 string 값
    static let resultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    /// 날짜 포맷변경
    /// 20250101 -> 2025.01.01
    static func dateFormat(_ date: String) -> String {
        guard let stringToDate = dateFormatter.date(from: date) else { return date }
        return resultDateFormatter.string(from: stringToDate)
    }
}
