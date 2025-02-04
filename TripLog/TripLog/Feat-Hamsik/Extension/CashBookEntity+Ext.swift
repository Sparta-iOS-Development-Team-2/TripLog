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
    var id = UUID()
    let tripName: String
    let note: String
    let budget: Int
    let departure: String
    let homecoming: String
}

extension CashBookEntity: CoreDataManagable {
    
    // TODO: 임시 데이터 적용 중, 수정 필요
    typealias Model = MockCashBookModel
    typealias Entity = CashBookEntity
    
    static func save(_ data: Model, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.CashBookEntity.rawValue
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        let fetchRequest: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", data.id as CVarArg)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            if existingItems.isEmpty {
                // 중복된 항목이 없으면 저장
                context.perform {
                    let att = NSManagedObject(entity: entity, insertInto: context)
                    att.setValue(data.budget, forKey: EntityKeys.CashBookElement.budget)
                    att.setValue(data.departure, forKey: EntityKeys.CashBookElement.departure)
                    att.setValue(data.homecoming, forKey: EntityKeys.CashBookElement.homecoming)
                    att.setValue(data.note, forKey: EntityKeys.CashBookElement.note)
                    att.setValue(data.tripName, forKey: EntityKeys.CashBookElement.tripName)
                }
                do {
                    try context.save()
                    print("저장 성공: \(data.note)")
                } catch {
                    print("데이터 저장 실패: \(error)")
                }
            } else {
                print("이미 존재하는 항목입니다.")
            }
        } catch {
            print("Fetch 오류: \(error.localizedDescription)")
        }
    }
    
    
    /// CashBookEntity의 전체/특정 데이터를 가져오는 함수
    /// predicate를 입력하지 않으면 전체 데이터 / 입력하면 특정 데이터
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 찾고자하는 가계부 이름(tripName)
    /// - Returns: 검색 결과
    static func fetch(context: NSManagedObjectContext, predicate: String? = nil) -> [Entity] {
        let request: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        
        guard let predicate = predicate else {
            // 검색 조건이 없을 때 동작
            do {
                let result = try context.fetch(request)
                print("모든 CashBookEntity fetch 성공")
                return result
            } catch {
                print("CashBookEntity Fetch 실패: \(error)")
                return []
            }
        }
        
        // 검색 조건이 있을 때 동작
        request.predicate = NSPredicate(format: "tripName == $@", predicate)
        do {
            let result = try context.fetch(request)
            for item in result {
                print("검색 결과: \n이름: \(item.value(forKey: "tripName") ?? "")")
            }
            return result
        } catch {
            print("데이터 읽기 실패: \(error)")
            return []
        }
    }
    
    /// CashBookEntity의 전체/특정 데이터를 업데이트하는 함수
    /// - Parameters:
    ///   - data: 업데이트할 데이터
    ///   - entityID: 업데이트할 Entity의 ID
    ///   - context: CoreData 인스턴스
    static func update(data: MockCashBookModel, entityID: UUID, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", entityID as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let entityToUpdate = results.first {
                context.perform {
                    entityToUpdate.setValue(data.budget, forKey: EntityKeys.CashBookElement.budget)
                    entityToUpdate.setValue(data.departure, forKey: EntityKeys.CashBookElement.departure)
                    entityToUpdate.setValue(data.homecoming, forKey: EntityKeys.CashBookElement.homecoming)
                    entityToUpdate.setValue(data.note, forKey: EntityKeys.CashBookElement.note)
                    entityToUpdate.setValue(data.tripName, forKey: EntityKeys.CashBookElement.tripName)
                }
                do {
                    try context.save()
                    print("업데이트 성공: \(data.note)")
                } catch {
                    print("데이터 저장 실패: \(error)")
                }
            } else {
                print("해당 UUID를 가진 엔티티를 찾을 수 없습니다.")
            }
            
        } catch {
            print("업데이트 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    static func delete(entityID: UUID, context: NSManagedObjectContext) {
        let persistantContainer = CoreDataManager.shared.persistentContainer
        let entityName = EntityKeys.Name.CashBookEntity.rawValue
        // Core Data 모델에서 해당 entity가 존재하는지 확인
        guard persistantContainer.managedObjectModel.entities.contains(where: { $0.value(forKey: "id") as! UUID == entityID }) else {
            debugPrint("⚠️ 삭제하려는 엔티티 '\(entityID)'가 존재하지 않습니다.")
            return
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", entityID as CVarArg)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            debugPrint("✅ \(entityName)에서 id \(entityID) 데이터 삭제 완료")
        } catch {
            debugPrint("❌ \(entityName)에서 id \(entityID) 데이터 삭제 실패: \(error)")
        }
    }
}
