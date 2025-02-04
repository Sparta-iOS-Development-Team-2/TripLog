//
//  ExpenseModel.swift
//  TripLog
//
//  Created by Jamong on 2/3/25.
//

import Foundation
import CoreData

// 리팩토링 후 데이터 변경 가능성 높음
// UI 테스트를 위해 구현해 놓음

// MARK: - Models
struct ExpenseModel {
    let date: Date
    let amount: Double
}

// MARK: - Currency Type
enum CurrencyType: String {
    case usd = "USD"
    case jpy = "JPY"
    case cny = "CNY"
    case krw = "KRW"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .jpy: return "¥"
        case .cny: return "¥"
        case .krw: return "₩"
        }
    }
}

// MARK: - ExpenseItem Model
/// 지출 항목을 나타내는 모델
struct ExpenseItem {
    let title: String
    let foreignAmount: Double?
    let currencyType: CurrencyType
    let category: String
    let paymentMethod: String
    let wonAmount: Double
}
