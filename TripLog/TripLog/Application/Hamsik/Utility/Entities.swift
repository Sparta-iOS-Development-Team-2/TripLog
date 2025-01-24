//
//  Entities.swift
//  TripLog
//
//  Created by 황석현 on 1/23/25.
//

import Foundation

enum EntityKeys {
    static let currencyEntity = "CurrencyEntity"
    static let cashBookEntity = "CashBookEntity"
    
    enum CurrencyElement {
        static let baseRate = "baseRate"
        static let currencyCode = "currencyCode"
        static let currencyName = "currencyName"
    }
    
    enum CashBookElement {
        static let budget = "budget"
        static let departure = "departure"
        static let homecoming = "homecoming"
        static let note = "note"
        static let tripName = "tripName"
    }
}
