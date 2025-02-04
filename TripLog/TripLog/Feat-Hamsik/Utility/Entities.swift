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
    let id = "id"
    let note = "note"
    let category = "category"
    let amount = "amount"
    let payment = "payment"
}

struct CashBookElement {
    let id = "id"
    let budget = "budget"
    let departure = "departure"
    let homecoming = "homecoming"
    let note = "note"
    let tripName = "tripName"

}
