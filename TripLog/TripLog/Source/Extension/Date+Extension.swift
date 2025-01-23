//
//  Date+Extension.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import Foundation

extension Date {
    /// Date를 입력하면 20250121 형태의 문자열을 출력
    static func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
}
