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
    
    
    /// 새로운 MyCashBookEntity를 저장하는 함수
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - context: CoreData 인스턴스
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
    
    /// MyCashBookEntity의 전체/특정 데이터를 가져오는 함수
    /// predicate를 입력하지 않으면 전체 데이터 / 입력하면 특정 데이터
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 찾고자하는 메모 이름(note)
    /// - Returns: 검색 결과
    static func fetch(context: NSManagedObjectContext, predicate: String? = nil) -> [Entity] {
        let request: NSFetchRequest<MyCashBookEntity> = MyCashBookEntity.fetchRequest()
        
        guard let predicate = predicate else {
            // 검색 조건이 없을 때 동작
            do {
                let result = try context.fetch(request)
                print("모든 MyCashBookEntity fetch 성공")
                return result
            } catch {
                print("MyCashBookEntity Fetch 실패: \(error)")
                return []
            }
        }
        
        // 검색 조건이 있을 때 동작
        request.predicate = NSPredicate(format: "note == $@", predicate)
        do {
            let result = try context.fetch(request)
            for item in result {
                print("검색 결과: \n이름: \(item.value(forKey: "note") ?? "")")
            }
            return result
        } catch {
            print("데이터 읽기 실패: \(error)")
            return []
        }
    }
    
    
}
