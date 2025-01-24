//
//  CashBookEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/24/25.
//

import Foundation
import CoreData

// TODO: 삭제 예정
struct MockCashBookModel { }

extension CashBookEntity: CoreDataManagable {
    
    typealias Model = MockCashBookModel
    typealias Entity = CashBookEntity
    
    func save(_ data: Any, context: NSManagedObjectContext) {
        let entityName = EntityKeys.cashBookEntity
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        context.perform {
            // TODO: 추후 데이터 타입 파일이 병합되면 아래에 주석을 수정&활성화할 예정
            /**
             //            let att = NSManagedObject(entity: entity, insertInto: context)
             //            att.setValue(data.budget, forKey: EntityKeys.CashBookElement.budget)
             //            att.setValue(data.departure, forKey: EntityKeys.CashBookElement.departure)
             //            att.setValue(data.homecoming, forKey: EntityKeys.CashBookElement.homecoming)
             //            att.setValue(data.note, forKey: EntityKeys.CashBookElement.note)
             //            att.setValue(data.tripName, forKey: EntityKeys.CashBookElement.tripName)
             */
        }
    }
    
    static func fetch(context: NSManagedObjectContext, predicate: NSPredicate?) -> [Entity] {
        let request: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        request.predicate = predicate
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
}
