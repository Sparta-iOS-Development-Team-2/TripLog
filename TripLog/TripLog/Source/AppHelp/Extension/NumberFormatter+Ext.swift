//
//  PriceFormatModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//
import Foundation

extension NumberFormatter {
    
    /// 1000 단위 구분
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    /// 세자릿 수 표현
    /// parmeter(Int) : 1000000
    /// return(String) : 1,000,000 원
    static func wonFormat(_ number: Int) -> String {
        let result = formatter.string(from: NSNumber(value: number)) ?? "0"
        return result + " 원"
    }
    
}

// 🔹 천 단위 숫자 포맷 변환 (소수점 유지)
extension NumberFormatter {
    static func formattedString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        // ✅ 정수라면 소수점 제거, 소수점이 있으면 최대 2자리 표시
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0  // 정수일 때 소수점 제거
        } else {
            formatter.minimumFractionDigits = 2  // 소수점이 있을 때 최소 2자리
            formatter.maximumFractionDigits = 2  // 소수점 2자리까지 표시
        }

        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
