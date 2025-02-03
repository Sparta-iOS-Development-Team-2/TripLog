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
    
    /// (사용X)
    ///
    /// 환율정보 특성상 개발자가 저장할 일이 발생하지 않아 구현하지 않음
    static func save(_ data: CurrencyRate, context: NSManagedObjectContext) { }
    
    /// (사용X)
    ///
    /// 환율정보 특성상 개발자가 저장할 일이 발생하지 않아 구현하지 않음
    static func update(data: CurrencyRate, entityID: UUID, context: NSManagedObjectContext) { }
    
    /// 새로운 환율정보를 생성하는 함수
    /// - Parameters:
    ///   - date: 생성할 환율날짜
    ///   - context: CoreData 인스턴스
    static func getCurrencyRate(date: String, context: NSManagedObjectContext) {
        let dataType = APIInfo.exchangeRate
        
        APIManager.shared.fetchCurrencyRatesWithAlamofire(dataType: dataType, date: date) { result in
            switch result {
            case .success(let currencyRates):
                // API 상태 코드 출력 (1:성공, 2:DATA코드 오류, 3:인증코드 오류, 4: 일일제한횟수 마감
                print("resultCode: \(String(describing: currencyRates[0].result))")
                print("resultCount: \(currencyRates.count)")
                // CoreData에 환율정보 저장
                saveToCoreData(currencyRates, date: date, context: context)
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
        
        /// 환율정보를 코어데이터에 저장하는 함수
        /// - Parameters:
        ///   - currencyRates: 저장할 환율정보
        ///   - date: 요청한 환율정보의 날짜
        ///   - context: CoreData 인스턴스
        func saveToCoreData(_ currencyRates: CurrencyRate, date: String, context: NSManagedObjectContext) {
            let keys = EntityKeys.CurrencyElement.self
            print("dataCount: \(currencyRates.count)")
            guard let entity = NSEntityDescription.entity(
                forEntityName: EntityKeys.Name.CurrencyEntity.rawValue, in: context
            ) else { return }
            context.perform {
                for item in currencyRates {
                    let entity = NSManagedObject(entity: entity, insertInto: context)
                    entity.setValue(date, forKey: keys.rateDate)
                    entity.setValue(item.curUnit, forKey: keys.currencyCode)
                    entity.setValue(item.curNm, forKey: keys.currencyName)
                    entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: keys.baseRate)
                }
                do {
                    try context.save()
                    print("환율 저장 완료")
                } catch {
                    print("🚫환율 저장 실패: \(error)")
                }
            }
        }
    }
    
    /// CoreData에 저장된 환율정보를 불러오는 함수
    /// - Parameters:
    ///   - context: CoreData 인스턴스
    ///   - predicate: 검색 값(미 입력 시 전체 환율 반환)
    /// - Returns: 검색결과(특정 검색 결과)
    static func fetch(context: NSManagedObjectContext, predicate: String? = nil) -> [Entity] {
        let request: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        
        guard let predicate = predicate else {
            // 검색 조건이 없을 때 동작
            do {
                let result = try context.fetch(request)
                print("모든 CurrencyEntity fetch 성공")
                return result
            } catch {
                print("CurrencyEntity Fetch 실패: \(error)")
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
            self.getCurrencyRate(date: predicate, context: context)
            return []
        }
    }
    
}
