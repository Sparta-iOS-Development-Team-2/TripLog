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
    let budget: Int
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
}
