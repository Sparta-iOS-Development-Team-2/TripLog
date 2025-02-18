//
//  CashBookEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/24/25.
//

import Foundation
import CoreData
import Differentiator

struct CashBookModel: Hashable, IdentifiableType {
    typealias Identity = UUID
    var identity: UUID {
        self.id
    }
    
    var id = UUID()
    let tripName: String
    let note: String
    let budget: Int
    let departure: String
    let homecoming: String
}

extension CashBookEntity: CoreDataManagable {
    
    typealias Model = CashBookModel
    typealias Entity = CashBookEntity
    
    
    /// CashBookEntity를 저장/생성하는 함수
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - context: CoreData 인스턴스
    static func save(_ data: Model, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.CashBookEntity.rawValue
        let element = CashBookElement()
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        let fetchRequest: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(element.tripName) == %@", data.tripName as CVarArg)
        let properties: [String: Any] = [
            element.id : data.id,
            element.budget : data.budget,
            element.departure : data.departure,
            element.homecoming : data.homecoming,
            element.note : data.note,
            element.tripName : data.tripName
        ]
        
        // 비동기 저장
        context.performAndWait {
            let att = NSManagedObject(entity: entity, insertInto: context)
            properties.forEach { key, value in
                att.setValue(value, forKey: key)
            }
            
            do {
                try context.save()
                debugPrint("저장 성공: \(data.note)")
            } catch {
                debugPrint("데이터 저장 실패: \(error)")
            }
        }
    }
    
    
    /// CashBookEntity의 전체/특정 데이터를 가져오는 함수
    /// predicate를 입력하지 않으면 전체 데이터 / 입력하면 특정 데이터
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 찾고자하는 가계부 이름(tripName)
    /// - Returns: 검색 결과
    static func fetch(context: NSManagedObjectContext, predicate: Any? = nil) -> [Entity] {
        let request: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        let element = CashBookElement()
        
        guard let predicate = predicate as? UUID else {
            // 검색 조건이 없을 때 동작
            do {
                let result = try context.fetch(request)
                debugPrint("모든 CashBookEntity fetch 성공: \(result.count)")
                return result
            } catch {
                debugPrint("CashBookEntity Fetch 실패: \(error)")
                return []
            }
        }
        
        // 검색 조건이 있을 때 동작
        request.predicate = NSPredicate(format: "\(element.id) == %@", predicate as CVarArg)
        do {
            let result = try context.fetch(request)
            for item in result {
                debugPrint("검색 결과: \n이름: \(item.value(forKey: element.tripName) ?? "")")
            }
            return result
        } catch {
            debugPrint("데이터 읽기 실패: \(error)")
            return []
        }
    }
    
    /// CashBookEntity의 전체/특정 데이터를 업데이트하는 함수
    /// - Parameters:
    ///   - data: 업데이트할 데이터
    ///   - entityID: 업데이트할 Entity의 ID
    ///   - context: CoreData 인스턴스
    static func update(data: CashBookModel, entityID: UUID, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        let element = CashBookElement()
        fetchRequest.predicate = NSPredicate(format: "\(element.id) == %@", entityID as CVarArg)
        let properties: [String: Any] = [
            element.budget : data.budget,
            element.departure : data.departure,
            element.homecoming : data.homecoming,
            element.note : data.note,
            element.tripName : data.tripName
        ]
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let entityToUpdate = results.first {
                // 비동기 저장
                context.performAndWait {
                    properties.forEach { key, value in
                        entityToUpdate.setValue(value, forKey: key)
                    }
                }
                
                do {
                    try context.save()
                    debugPrint("업데이트 성공: \(data.note)")
                } catch {
                    debugPrint("데이터 저장 실패: \(error)")
                }
            } else {
                debugPrint("해당 UUID를 가진 엔티티를 찾을 수 없습니다.")
            }
            
        } catch {
            debugPrint("업데이트 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    /// CashBookEntity를 삭제하는 함수
    /// - Parameters:
    ///   - entityID: 삭제할 CashBookEntity ID
    ///   - context: CoreData 인스턴스
    static func delete(entityID: UUID?, context: NSManagedObjectContext) {
        let cashBookEntityName = EntityKeys.Name.CashBookEntity.rawValue
        let cashBookID = CashBookElement().id
        let myCashBookEntityName = EntityKeys.Name.MyCashBookEntity.rawValue
        let myCashBookParentID = MyCashBookElement().cashBookID
        guard let entityID = entityID else { return }
        
        let cashBookFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: cashBookEntityName)
        cashBookFetchRequest.predicate = NSPredicate(format: "\(cashBookID) == %@", entityID as CVarArg)
        let cashBookDeleteRequest = NSBatchDeleteRequest(fetchRequest: cashBookFetchRequest)
        
        let myCashBookFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: myCashBookEntityName)
        myCashBookFetchRequest.predicate = NSPredicate(format: "\(myCashBookParentID) == %@", entityID as CVarArg)
        let myCashBookDeleteRequest = NSBatchDeleteRequest(fetchRequest: myCashBookFetchRequest)
        
        do {
            try context.execute(cashBookDeleteRequest)
            try context.execute(myCashBookDeleteRequest)
            context.refreshAllObjects()
            debugPrint("\(cashBookEntityName)에서 id \(entityID) 데이터 삭제 완료")
        } catch {
            debugPrint("\(cashBookEntityName)에서 id \(entityID) 데이터 삭제 실패: \(error)")
        }
    }
}
