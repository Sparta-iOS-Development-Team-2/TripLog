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
    
    static func getPreviousDate(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // 문자열 -> Date 변환
        guard let date = dateFormatter.date(from: dateString) else {
            print("잘못된 날짜 형식입니다.")
            return nil
        }
        
        // 하루 감소한 날짜 생성
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)
        
        // Date -> 문자열 변환
        guard let resultDate = previousDate else { return nil }
        return dateFormatter.string(from: resultDate)
    }
}
