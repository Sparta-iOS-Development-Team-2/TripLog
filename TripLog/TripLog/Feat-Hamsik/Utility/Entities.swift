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
}
struct CurrencyElement {
    let rateDate = "rateDate"
    let baseRate = "baseRate"
    let currencyCode = "currencyCode"
    let currencyName = "currencyName"
}

struct MyCashBookElement {
    let amount = "amount"
    let caculatedAmount = "caculatedAmount"
    let category = "category"
    let cashBookID = "cashBookID"
    let country = "country"
    let expenseDate = "expenseDate"
    let id = "id"
    let note = "note"
    let payment = "payment"
}

struct CashBookElement {
    let budget = "budget"
    let departure = "departure"
    let homecoming = "homecoming"
    let id = "id"
    let note = "note"
    let tripName = "tripName"
}
