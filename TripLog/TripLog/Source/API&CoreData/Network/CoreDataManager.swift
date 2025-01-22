//
//  NetworkManager.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("AppDelegate가 초기화되지 않았습니다.")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    
    /// 환율 정보를 코어데이터에 저장하기
    func fetchCurrenyRates() {
        // 환율
        let dataType = APIInfo.exchangeRate
        
        APIManager.shared.fetchCurrencyRatesWithAlamofire(
            dataType: dataType, date: Date()) { [weak self] result in
                switch result {
                case .success(let currencyRates):
                    // API 상태 코드 출력 (1:성공, 2:DATA코드 오류, 3:인증코드 오류, 4: 일일제한횟수 마감
                    print("resultCode: \(String(describing: currencyRates[0].result))")
                    self?.saveCurrencyRates(from: currencyRates)
                case .failure(let error):
                    print("🚫Rates Load Failed: \(error)")
                }
            }
    }
    
    /// CoreData에 환율정보 저장
    func saveCurrencyRates(from apiData: CurrencyRate) {
        guard let context = CoreDataManager.shared.context else { return }
        guard let entity = NSEntityDescription.entity(
            forEntityName: "CurrencyEntity", in: context
        ) else { return }
        context.perform {
            for item in apiData {
                let entity = NSManagedObject(entity: entity, insertInto: context)
                entity.setValue(item.curUnit, forKey: "currencyCode")
                entity.setValue(item.curNm, forKey: "currencyName")
                entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: "baseRate")
            }
            do {
                try CoreDataManager.shared.context?.save()
                print("환율 저장 완료")
            } catch {
                print("🚫환율 저장 실패: \(error)")
            }
        }
    }
    
    /// CoreData에서 데이터 가져오기
    func fetchStoredCurrencyRates() -> [CurrencyEntity] {
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do {
            guard let results = try CoreDataManager.shared.context?.fetch(fetchRequest) else { return [] }
            return results
        } catch {
            print("🚫 데이터 가져오기 실패: \(error)")
            return []
        }
    }
    
}
