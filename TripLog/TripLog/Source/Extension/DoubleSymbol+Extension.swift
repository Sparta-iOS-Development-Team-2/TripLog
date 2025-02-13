//
//  DoubleSymbol+Extension.swift
//  TripLog
//
//  Created by 김석준 on 2/13/25.
//

import Foundation

extension Double {
    /// 통화 코드에 따른 통화 기호 매핑
    private static let currencyCodeToSymbol: [String: String] = [
        "AED": "﷼", "AUD": "A$", "BHD": "﷼", "BND": "B$", "CAD": "C$",
        "CHF": "SFr", "CNH": "¥", "DKK": "kr", "EUR": "€", "GBP": "£",
        "HKD": "HK$", "IDR": "Rp", "JPY": "¥", "KRW": "₩", "KWD": "﷼",
        "MYR": "RM", "NOK": "kr", "NZD": "NZ$", "SAR": "﷼", "SEK": "kr",
        "SGD": "S$", "THB": "฿", "USD": "$"
    ]
    
    /// 💰 **모든 통화 기호가 앞에 오고, 소수점 대신 쉼표(`,`)를 사용**
    func formattedCurrency(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US") // 기본 로케일 설정
        
        // ✅ 천 단위 구분자를 쉼표(`,`)로 설정
        formatter.groupingSeparator = ","
        
        // ✅ 소수점 대신 쉼표(`,`) 사용
        formatter.decimalSeparator = ","
        
        // ✅ 소수점 자리수 설정
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0  // 정수일 때 소수점 제거
        } else {
            formatter.minimumFractionDigits = 2  // 소수점 2자리 유지
            formatter.maximumFractionDigits = 2
        }
        
        // ✅ 통화 기호 설정
        let symbol = Self.currencyCodeToSymbol[currencyCode] ?? currencyCode
        formatter.currencySymbol = symbol + " "
        
        // ✅ 최종 포맷된 문자열 반환
        if let formattedString = formatter.string(from: NSNumber(value: self)) {
            return formattedString.replacingOccurrences(of: ".", with: ",")
        } else {
            return "\(symbol) \(self)"
        }
    }
}
