//
//  String+Extension.swift
//  TripLog
//
//  Created by 김석준 on 2/12/25.
//
import Foundation

extension String {
    /// `yyyyMMdd` 형식의 문자열을 `yyyy.MM.dd` 형식으로 변환
    func formattedDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        }
        return self
    }
}
