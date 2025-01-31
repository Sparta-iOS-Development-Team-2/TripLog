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

    
    /// API로 받아온 데이터를 CoreData에 저장하는 함수
    /// - Parameters:
    ///   - data: 저장할 데이터(사용하지 않음)
    ///   - context: CoreData 객체
    ///   - save(): 본 함수 내에서만 동작하는 환율저장 로직
    static func save(_ data: CurrencyRate, context: NSManagedObjectContext) {
        let dataType = APIInfo.exchangeRate
        
        APIManager.shared.fetchCurrencyRatesWithAlamofire(dataType: dataType, date: "") { result in
            switch result {
            case .success(let currencyRates):
                // API 상태 코드 출력 (1:성공, 2:DATA코드 오류, 3:인증코드 오류, 4: 일일제한횟수 마감
                print("resultCode: \(String(describing: currencyRates[0].result))")
                print("resultCount: \(currencyRates.count)")
                saveToCoreData(currencyRates)
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
        
        func saveToCoreData(_ currencyRates: CurrencyRate) {
            let keys = EntityKeys.CurrencyElement.self
            print("dataCount: \(currencyRates.count)")
            guard let entity = NSEntityDescription.entity(
                forEntityName: EntityKeys.currencyEntity, in: context
            ) else { return }
            context.perform {
                for item in currencyRates {
                    let entity = NSManagedObject(entity: entity, insertInto: context)
                    entity.setValue(item.curUnit, forKey: keys.currencyCode)
                    entity.setValue(item.curNm, forKey: keys.currencyName)
                    entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: keys.baseRate)
                }
                do {
                    try context.save()
                    print("환율 저장 완료: \(data.count)")
                } catch {
                    print("🚫환율 저장 실패: \(error)")
                }
            }
        }
    }
    
    
    /// CoreData에 저장된 환율정보를 불러오는 함수
    /// - Parameter context: CoreData 객체
    /// - Returns: 환율정보(각 나라별 환율)
    static func fetch(context: NSManagedObjectContext) -> [Entity] {
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            print("CurrencyEntity fetch success: \(results.count)")
            return results
        } catch {
            print("CurrencyEntity fetch failed: \(error)")
            return []
        }
    }
    
}
