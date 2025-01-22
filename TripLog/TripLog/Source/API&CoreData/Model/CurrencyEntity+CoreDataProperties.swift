//
//  CurrencyEntity+CoreDataProperties.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//
//

import Foundation
import CoreData


extension CurrencyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyEntity> {
        return NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
    }

    @NSManaged public var baseRate: Double
    @NSManaged public var currencyCode: String?
    @NSManaged public var currencyName: String?

}

extension CurrencyEntity : Identifiable {

}
