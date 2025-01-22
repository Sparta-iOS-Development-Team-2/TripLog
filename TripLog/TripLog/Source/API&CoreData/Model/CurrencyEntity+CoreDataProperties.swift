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

    @NSManaged public var baseRate: Double // 환율
    @NSManaged public var currencyCode: String? // 환율코드(예: KRW)
    @NSManaged public var currencyName: String? // 환율이름(예: 한국 원)

}

extension CurrencyEntity : Identifiable {

}
