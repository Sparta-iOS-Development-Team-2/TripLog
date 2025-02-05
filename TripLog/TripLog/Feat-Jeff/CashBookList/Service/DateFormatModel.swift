//
//  DateFormatModel.swift
//  TripLog
//
//  Created by jae hoon lee on 2/5/25.
//

import Foundation

extension Formatter {
    
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
