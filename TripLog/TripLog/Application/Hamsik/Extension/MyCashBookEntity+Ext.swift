//
//  MyCashBookEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/31/25.
//

import Foundation
import CoreData

// TODO: 임시데이터(삭제예정)
struct MockMyCashBookModel {
    let note: String
    let category: String
    let amount: Double
    let payment: Bool
}

extension MyCashBookEntity: CoreDataManagable {
    
    // TODO: 임시 데이터 적용 중, 수정 필요
    typealias Model = MockMyCashBookModel
    typealias Entity = MyCashBookEntity
    
    static func save(_ data: Model, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.MyCashBookEntity.rawValue
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        context.perform {
            let att = NSManagedObject(entity: entity, insertInto: context)
            att.setValue(data.amount, forKey: EntityKeys.MyCashBookElement.amount)
            att.setValue(data.category, forKey: EntityKeys.MyCashBookElement.category)
            att.setValue(data.note, forKey: EntityKeys.MyCashBookElement.note)
            att.setValue(data.payment, forKey: EntityKeys.MyCashBookElement.payment)
        }
    }
    
    static func fetch(context: NSManagedObjectContext) -> [Entity] {
        let request: NSFetchRequest<MyCashBookEntity> = MyCashBookEntity.fetchRequest()
        do {
            let result = try context.fetch(request)
            print("MyCashBookEntity fetch success")
            return result
        } catch {
            print("MyCashBookEntity Fetch failed: \(error)")
            return []
        }
    }
    
    
}
