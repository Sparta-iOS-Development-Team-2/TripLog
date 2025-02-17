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
    static func formattedDateDotString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: date)
    }
    
    static func getPreviousDate(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // 문자열 -> Date 변환
        guard let date = dateFormatter.date(from: dateString) else {
            debugPrint("잘못된 날짜 형식입니다.")
            return nil
        }
        
        // 하루 감소한 날짜 생성
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)
        
        // Date -> 문자열 변환
        guard let resultDate = previousDate else { return nil }
        return dateFormatter.string(from: resultDate)
    }
    
    /// 날짜 계산 메서드(coreData의 rateDate값 사용)
    /// 추후 사용시 CalculateDate.calculateDate()로 사용
    static func caculateDate() -> String {
        let calendar = Calendar.current
        
        let todayDate = Date.formattedDateString(from: Date())
        
        guard let fetchRateDate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayDate).first,
              let rateDate = fetchRateDate.rateDate,
              let currencyDate = Formatter.rateDateValue(rateDate)
        else {
            return ""
        }
        
        guard let calculateDate = calendar.dateComponents([.day], from: currencyDate, to: Date()).day
        else {
            return "Error"
        }
        
        switch calculateDate {
        case 0 :
            return "금일"
        default :
            return "\(calculateDate)일 전"
        }
    }
}
