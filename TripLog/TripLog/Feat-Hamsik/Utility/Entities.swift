//
//  Entities.swift
//  TripLog
//
//  Created by 황석현 on 1/23/25.
//

import Foundation

enum EntityKeys {
    
    enum Name: String {
        case CurrencyEntity, CashBookEntity, MyCashBookEntity
    }
    
    enum CurrencyElement {
        static let rateDate = "rateDate"
        static let baseRate = "baseRate"
        static let currencyCode = "currencyCode"
        static let currencyName = "currencyName"
    }
    
    enum CashBookElement {
        static let id = "id"
        static let budget = "budget"
        static let departure = "departure"
        static let homecoming = "homecoming"
        static let note = "note"
        static let tripName = "tripName"
    }
    
    enum MyCashBookElement {
        static let id = "id"
        static let note = "note"
        static let category = "category"
        static let amount = "amount"
        static let payment = "payment"
    }
}
