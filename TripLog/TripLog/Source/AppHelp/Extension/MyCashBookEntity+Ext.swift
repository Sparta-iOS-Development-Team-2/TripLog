//
//  MyCashBookEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/31/25.
//

import Foundation
import CoreData

struct MyCashBookModel {
    let amount: Double // 지출금액
    let cashBookID: UUID // 가계부 Entity ID
    let caculatedAmount: Double // 계산값(원화)
    let category: String // 카테고리
    let country: String // 환율코드
    let expenseDate: Date // 지출일자
    var id = UUID() // 자체 ID
    let note: String // 설명
    let payment: Bool // 결제수단
}

extension MyCashBookEntity: CoreDataManagable {
    
    typealias Model = MyCashBookModel
    typealias Entity = MyCashBookEntity
    
    
    /// 새로운 MyCashBookEntity를 저장하는 함수
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - context: CoreData 인스턴스
    static func save(_ data: Model, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.MyCashBookEntity.rawValue
        let element = MyCashBookElement()
        guard let entity = NSEntityDescription.entity(forEntityName:
                                                        entityName,
                                                      in: context) else { return }
    
        let properties: [String: Any] = [
            element.amount : data.amount,
            element.caculatedAmount : data.caculatedAmount,
            element.category : data.category,
            element.cashBookID : data.cashBookID,
            element.country : data.country,
            element.expenseDate : data.expenseDate,
            element.id : data.id,
            element.note : data.note,
            element.payment : data.payment
        ]
        
        // 비동기 저장
        context.performAndWait {
            let att = NSManagedObject(entity: entity, insertInto: context)
            properties.forEach { key, value in
                att.setValue(value, forKey: key)
            }

            do {
                try context.save()
                print("저장 성공: \(data.note)")
            } catch {
                print("데이터 저장 실패: \(error)")
            }
        }
        
    }
    
    /// MyCashBookEntity의 전체/특정 데이터를 가져오는 함수
    /// predicate를 입력하지 않으면 전체 데이터 / 입력하면 특정 데이터
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 가계부 ID(UUID)(필수!)
    /// - Returns: 검색 결과
    static func fetch(context: NSManagedObjectContext, predicate: Any?) -> [Entity] {
        let request: NSFetchRequest<MyCashBookEntity> = MyCashBookEntity.fetchRequest()
        let element = MyCashBookElement()
        
        guard let predicate = predicate as? UUID else {
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
        request.predicate = NSPredicate(format: "\(element.cashBookID) == %@", predicate as CVarArg)
        do {
            let result = try context.fetch(request)
            for item in result {
                print("검색 결과: \n이름: \(item.value(forKey: element.cashBookID) ?? "")")
            }
            return result
        } catch {
            print("데이터 읽기 실패: \(error)")
            return []
        }
    }
    
    
    /// MyCashBookEntity의 전체/특정 데이터를 업데이트하는 함수
    /// - Parameters:
    ///   - data: 업데이트할 데이터
    ///   - entityID: 업데이트할 Entity의 ID
    ///   - context: CoreData 인스턴스
    static func update(data: MyCashBookModel, entityID: UUID, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<MyCashBookEntity> = MyCashBookEntity.fetchRequest()
        let element = MyCashBookElement()
        fetchRequest.predicate = NSPredicate(format: "\(element.id) == %@", entityID as CVarArg)
        let properties: [String: Any] = [
            element.amount : data.amount,
            element.caculatedAmount : data.caculatedAmount,
            element.category : data.category,
            element.cashBookID : data.cashBookID,
            element.country : data.country,
            element.expenseDate : data.expenseDate,
            element.note : data.note,
            element.payment : data.payment
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
    
    
    /// MyCashBookEntity의 데이터를 삭제하는 함수
    /// - Parameters:
    ///   - entityID: 삭제할 EntityID
    ///   - context: CoreData 인스턴스
    static func delete(entityID: UUID?, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.MyCashBookEntity.rawValue
        let element = MyCashBookElement()
        guard let entityID = entityID else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(element.id) == %@", entityID as CVarArg)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            context.refreshAllObjects()
            debugPrint("\(entityName)에서 id \(entityID) 데이터 삭제 완료")
        } catch {
            debugPrint("\(entityName)에서 id \(entityID) 데이터 삭제 실패: \(error)")
        }
    }
}

extension MyCashBookEntity {
    
    /// 화면의 날짜별 지출내역 가져오는 함수
    /// - Parameter expenseDate: 가져올 지출내역 날짜
    /// - Returns: [지출내역]
    func getCurrentMyCashBook(expenseDate: Date) -> [MyCashBookEntity] {
        let context = CoreDataManager.shared.context
        let predicate = Date.formattedDateString(from: expenseDate)
        let element = MyCashBookElement()
        
        let request: NSFetchRequest<MyCashBookEntity> = MyCashBookEntity.fetchRequest()
        request.predicate = NSPredicate(format: "\(element.expenseDate) == $@",
                                        predicate as String)
        
        do {
            let result = try context.fetch(request)
            print("모든 MyCashBookEntity fetch 성공")
            return result
        } catch {
            print("MyCashBookEntity Fetch 실패: \(error)")
            return []
        }
    }
}
