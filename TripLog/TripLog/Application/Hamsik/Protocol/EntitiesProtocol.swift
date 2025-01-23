//
//  EntitiesProtocol.swift
//  TripLog
//
//  Created by 황석현 on 1/23/25.
//

import Foundation

protocol CurrencyEntitySaveable {
    func save(data: Any)
    func fetch() -> [Any]
    func upadte(data: Any)
    func delete(data: Any)
}

protocol CashBookEntitySaveable {
    func save(data: Any)
    func fetch() -> [Any]
    func upadte(data: Any)
    func delete(data: Any)
}
