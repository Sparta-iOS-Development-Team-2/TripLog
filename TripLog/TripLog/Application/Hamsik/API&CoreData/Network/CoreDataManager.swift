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
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: AppInfo.appId)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
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
        let keys = EntityKeys.CurrencyElement.self
        guard let entity = NSEntityDescription.entity(
            forEntityName: EntityKeys.currencyEntity, in: context
        ) else { return }
        context.perform {
            for item in apiData {
                let entity = NSManagedObject(entity: entity, insertInto: self.context)
                entity.setValue(item.curUnit, forKey: keys.currencyCode)
                entity.setValue(item.curNm, forKey: keys.currencyName)
                entity.setValue(Double(item.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "1") ?? 1.0, forKey: keys.baseRate)
            }
            do {
                try self.context.save()
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
            let results = try self.context.fetch(fetchRequest)
            return results
        } catch {
            print("🚫 데이터 가져오기 실패: \(error)")
            return []
        }
    }
    
    func save<T: CoreDataManagable>(type: T, data: T.Model) {
        type.save(data, context: context)
        saveContext()
    }
    
    func fetch<T: CoreDataManagable>(type: T.Type, predicate: NSPredicate? = nil) -> [T.Entity] {
        return type.fetch(context: context, predicate: predicate)
    }
    
    func delete<T: NSManagedObject>(_ object: T) {
        context.delete(object)
        saveContext()
    }
    
    func search<T: NSManagedObject>(_ objectType: T.Type, id: NSManagedObjectID) -> T? {
        do {
            return try context.existingObject(with: id) as? T
        } catch {
            print("🚫 Search failed: \(error)")
            return nil
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
