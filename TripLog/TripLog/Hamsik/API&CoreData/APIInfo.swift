//
//  Untitled.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import Foundation

enum APIInfo {
    /// 인증키
    static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "APIKey") as? String else {
            fatalError("🚫 APIKey not found in Info.plist")
        }
        return apiKey
    }
    /// 환율
    static let exchangeRate = "AP01"
    /// 대출금리
    static let loanInterestRate = "AP02"
    /// 국제금리
    static let globalInterestRate = "AP03"
}
