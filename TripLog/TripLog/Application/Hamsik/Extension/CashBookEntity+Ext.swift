//
//  CashBookEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/24/25.
//

import Foundation
import CoreData

// TODO: 임시데이터(삭제예정)
struct MockCashBookModel {
    let budget: Double
    let departure: String
    let homecoming: String
    let note: String
    let tripName: String
}

extension CashBookEntity: CoreDataManagable {
    
    // TODO: 임시 데이터 적용 중, 수정 필요
    typealias Model = MockCashBookModel
    typealias Entity = CashBookEntity
    
    static func save(_ data: Model, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.CashBookEntity.rawValue
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        context.perform {
                let att = NSManagedObject(entity: entity, insertInto: context)
                att.setValue(data.budget, forKey: EntityKeys.CashBookElement.budget)
                att.setValue(data.departure, forKey: EntityKeys.CashBookElement.departure)
                att.setValue(data.homecoming, forKey: EntityKeys.CashBookElement.homecoming)
                att.setValue(data.note, forKey: EntityKeys.CashBookElement.note)
                att.setValue(data.tripName, forKey: EntityKeys.CashBookElement.tripName)
        }
    }
    
    static func fetch(context: NSManagedObjectContext) -> [Entity] {
        let request: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        do {
            let result = try context.fetch(request)
            print("CashBookEntity fetch success")
            return result
        } catch {
            print("CashBookEntity Fetch failed: \(error)")
            return []
        }
    }
}
