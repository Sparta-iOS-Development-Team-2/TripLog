//
//  CalculateDate.swift
//  TripLog
//
//  Created by jae hoon lee on 2/10/25.
//

import Foundation

struct CalculateDate {
    
    /// 날짜 계산 메서드(coreData의 rateDate값 사용)
    /// 추후 사용시 CalculateDate.calculateDate()로 사용
    static func calculateDate() -> String {
        let calendar = Calendar.current
        
        guard let fetchRateDate = CoreDataManager.shared.fetch(type: CurrencyEntity.self).first,
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
    
    /// 임시 날짜 계산 함수(삭제 예정)
    static func testCalculateDate(last: Date) -> String {
        let calendar = Calendar.current
        
        guard let calculateDate = calendar.dateComponents([.day], from: last, to: Date()).day
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
