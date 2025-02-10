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
                print("환율 저장 완료")
            } catch {
                print("환율 저장 실패: \(error)")
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
        let element = CurrencyElement()
        var result = [CurrencyEntity]()
        var resultType: CurrencyRateResultType = .isEmpty
        var retryCount = 0
        
        request.fetchLimit = 1
        
        guard var searchDate = predicate as? String else { return [] }
        
        while retryCount < 15 {
            // 검색 조건이 있을 때 동작
            request.predicate = NSPredicate(format: "\(element.rateDate) == %@", searchDate)
            do {
                result = try context.fetch(request)
                resultType = checkResult(result)
                
                switch resultType {
                    // 데이터 자체가 없을 때(생성하기)
                case .isEmpty:
                    retryCount += 1
                    FireStoreManager.shared.generateCurrencyRate(date: searchDate) {
                        Task {
                            print("\(searchDate) 데이터 생성")
                            do {
                                try await SyncManager.shared.syncCoreDataToFirestore()
                                print("동기화 완료") // 동기화 완료가 좀 느리게 동작함
                            } catch {
                                print("\(searchDate)데이터 생성 후 데이터 동기화 실패")
                            }
                        }
                    }
                    continue
                    
                    // 데이터에 내용이 없을 때(검색일자 감소)
                case .noData:
                    retryCount += 1
                    // 검색 조건을 수정하거나 사용자에게 알림
                    print("검색날짜 변경 전: \(searchDate)")
                    searchDate = Date.getPreviousDate(from: searchDate) ?? searchDate
                    print("검색날짜 변경 후: ->\(searchDate)")
                    continue
                    
                    // 정상 데이터 확인
                case .success:
                    print("정상 값 찾음: \(searchDate)")
                    return result // 반복문 종료
                }
            } catch {
                print("오류 발생: \(error)")
                return []
            }
        }
        
        func checkResult(_ result: [CurrencyEntity?]) -> CurrencyRateResultType {
            if result.isEmpty {
                return .isEmpty
            } else if result.first??.currencyCode == nil {
                return .noData
            } else {
                return .success
            }
        }
        return []
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
            print("\(entityName)의 모든 데이터가 삭제되었습니다.")
        } catch {
            print("데이터 삭제 중 오류 발생: \(error.localizedDescription)")
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
            print("dataCount: \(currencyRates.count)")
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
                    print("환율 저장 완료")
                } catch {
                    print("환율 저장 실패: \(error)")
                }
            }
        }
    }
}
