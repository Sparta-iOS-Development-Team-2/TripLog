//
//  Date+Extension.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import Foundation

extension Date {
    static func formattedDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
}
