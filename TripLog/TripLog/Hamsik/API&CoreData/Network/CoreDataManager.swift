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
    
    private static let context: NSManagedObjectContext? = {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("AppDelegate가 초기화되지 않았습니다.")
                return nil
            }
            return appDelegate.persistentContainer.viewContext
        }()

    
    /// 환율 정보를 코어데이터에 저장하기
    func fetchCurrenyRates() {
        let dataType = APIInfo.exchangeRate // 환율

        NetworkManager.shared.fetchCurrencyRatesWithAlamofire(dataType: dataType, date: Date()) { [weak self] result in
            switch result {
            case .success(let currencyRates):
                print("resultCode: \(String(describing: currencyRates[0].result))")
                self?.saveCurrenyRates(from: currencyRates)
                print("currencyRates count :", currencyRates.count)
            case .failure(let error):
                print("Rates Load Failed: \(error)")
            }
        }
    }
    
    func saveCurrenyRates(from apiData: CurrencyRate) {
        guard let context = CoreDataManager.context else { return }
        guard let entity = NSEntityDescription.entity(
            forEntityName: "CurrencyEntity", in: context
        ) else { return }
        context.perform {
            for item in apiData {
                let entity = NSManagedObject(entity: entity, insertInto: context)
                entity.setValue(item.curUnit, forKey: "currencyCode")
                entity.setValue(item.curNm, forKey: "currencyName")
                entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0.0, forKey: "baseRate")
            }
            do {
                try CoreDataManager.context?.save()
                print("환율 저장 완료")
            } catch {
                print("🚫환율 저장 실패: \(error)")
            }
        }
    }

    
    func fetchStoredCurrencyRates() -> [CurrencyEntity] {
        let fetchRequest: NSFetchRequest<CurrencyEntity> = CurrencyEntity.fetchRequest()
        do {
            guard let results = try CoreDataManager.context?.fetch(fetchRequest) else { return [] }
            return results
        } catch {
            print("🚫 데이터 가져오기 실패: \(error)")
            return []
        }
    }

}
