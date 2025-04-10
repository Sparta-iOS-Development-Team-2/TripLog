//
//  CurrencyEntity+Ext.swift
//  TripLog
//
//  Created by 황석현 on 1/26/25.
//

import Foundation
import CoreData

extension CurrencyEntity: CoreDataManagable {
    
    typealias Model = CurrencyRate
    typealias Entity = CurrencyEntity
    
    static func save(_ data: CurrencyRate, context: NSManagedObjectContext) {
        let element = CurrencyElement()
        guard let entity = NSEntityDescription.entity(
            forEntityName: EntityKeys.Name.CurrencyEntity.rawValue, in: context
        ) else { return }
        context.perform {
            for item in data {
                let entity = NSManagedObject(entity: entity, insertInto: context)
                entity.setValue(item.rateDate, forKey: element.rateDate)
                entity.setValue(item.curUnit, forKey: element.currencyCode)
                entity.setValue(item.curNm, forKey: element.currencyName)
                entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: element.baseRate)
            }
            do {
                try context.save()
                debugPrint("환율 저장 완료")
            } catch {
                debugPrint("환율 저장 실패: \(error)")
            }
        }
    }
    
    /// CoreData에 저장된 환율정보를 불러오는 함수
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 검색 값(미 입력 시 전체 환율 반환)
    /// - Returns: 검색결과(특정 검색 결과)
    static func fetch(context: NSManagedObjectContext, predicate: Any? = nil) -> [Entity] {
        let request: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        var result = [CurrencyEntity]()
        
        do {
            result = try context.fetch(request)
            result.sort(by: { Int($0.rateDate ?? "") ?? 0 > Int($1.rateDate ?? "") ?? 0 })
        } catch {
            debugPrint("코어 데이터 load 실패", error.localizedDescription)
            return []
        }
        
        guard let searchDate = predicate as? String,
              result.filter({ $0.rateDate == searchDate }).isEmpty
        else {
            debugPrint("✨ 환율 데이터 있음, 현재 최신 환율 데이터 날짜:", result.first?.rateDate ?? "nil")
            return result
        }

        
        // 검색 조건이 있을 경우
        FireStoreManager.shared.generateCurrencyRate(date: searchDate) { isSuccess in
            if isSuccess {
                Task {
                    do {
                        try await SyncManager.shared.syncCoreDataToFirestore()
                        result = try context.fetch(request)
                        result.sort(by: { Int($0.rateDate ?? "") ?? 0 > Int($1.rateDate ?? "") ?? 0 })
                        debugPrint("✅ 데이터 연동 성공!")
                        
                        return result
                        
                    } catch {
                        debugPrint("❌ Firestore 연동 실패", error.localizedDescription)
                        return result
                    }
                }
                
            } else {
                debugPrint("❌ API 통신 실패")
            }
        }
        
        debugPrint("✨ result를 반환합니다 ✨")
        
        return result
    }
    
    /// (사용X)
    ///
    /// 환율정보 특성상 개발자가 저장할 일이 발생하지 않아 구현하지 않음
    static func update(data: CurrencyRate, entityID: UUID, context: NSManagedObjectContext) { }
    
    
    static func delete(entityID: UUID?, context: NSManagedObjectContext) {
        let entityName = EntityKeys.Name.CurrencyEntity.rawValue
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            debugPrint("\(entityName)의 모든 데이터가 삭제되었습니다.")
        } catch {
            debugPrint("데이터 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    /// 새로운 환율정보를 생성하는 함수
    /// - Parameters:
    ///   - date: 조회할 환율날짜
    ///   - context: CoreData 인스턴스
    static func getDataFromFirestore(date: String, context: NSManagedObjectContext) {
        
        FireStoreManager.shared.getStoreCurrencyRate(date: date) { result in
            saveToCoreData(result, date: date, context: context)
        }
        
        /// 환율정보를 코어데이터에 저장하는 함수
        /// - Parameters:
        ///   - currencyRates: 저장할 환율정보
        ///   - date: 요청한 환율정보의 날짜
        ///   - context: CoreData 인스턴스
        func saveToCoreData(_ currencyRates: CurrencyRate, date: String, context: NSManagedObjectContext) {
            let element = CurrencyElement()
            debugPrint("dataCount: \(currencyRates.count)")
            guard let entity = NSEntityDescription.entity(
                forEntityName: EntityKeys.Name.CurrencyEntity.rawValue, in: context
            ) else { return }
            context.perform {
                for item in currencyRates {
                    let entity = NSManagedObject(entity: entity, insertInto: context)
                    entity.setValue(date, forKey: element.rateDate)
                    entity.setValue(item.curUnit, forKey: element.currencyCode)
                    entity.setValue(item.curNm, forKey: element.currencyName)
                    entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: element.baseRate)
                }
                do {
                    try context.save()
                    debugPrint("환율 저장 완료")
                } catch {
                    debugPrint("환율 저장 실패: \(error)")
                }
            }
        }
    }
}
