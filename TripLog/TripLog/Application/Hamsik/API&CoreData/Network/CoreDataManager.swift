//
//  NetworkManager.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import CoreData
import UIKit

/// CoreData 저장, 로드관련 매니져
class CoreDataManager {
    
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    
    private init(container: NSPersistentContainer = NSPersistentContainer(name: AppInfo.appId)) {
            self.persistentContainer = container
            self.persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Unresolved error \(error)")
                }
            }
        }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Functions for CoreData
    
    /// CoreData에 Entity를 저장하는 함수
    /// - Parameters:
    ///   - type: 저장할 Entity 타입(예: CashEntity.self)
    ///   - data: 저장할 데이터(예: CashBookModel)
    func save<T: CoreDataManagable>(type: T.Type, data: T.Model) {
        T.save(data, context: context)
        saveContext()
    }
    
    
    /// CoreData에 저장된 Entity를 불러오는 함수
    /// - Parameters:
    ///   - type: 불러올 Entity 타입(예: CashEntity.self)
    ///   - predicate: 검색할 특정 문자
    ///   (예: let predicate = NSPredicate(format: "tripName CONTAINS[cd] %@", "trip1"))
    /// - Returns: 검색결과
    func fetch<T: CoreDataManagable>(type: T.Type, predicate: NSPredicate? = nil) -> [T.Entity] {
        return type.fetch(context: context)
    }
    
    
    /// 특정 단일 Entity를 삭제하는 함수
    /// - Parameter object: 삭제할 하나의 Entity
    ///
    /// 전체 엔티티가 아닌 입력한 하나의 Entity 삭제됩니다.
    func delete<T: NSManagedObject>(_ object: T) {
        context.delete(object)
        saveContext()
    }
    
    /// 특정 Entity를 삭제하는 함수
    func removeEntity(entityName: String) {
        // Core Data 모델에서 해당 entity가 존재하는지 확인
        guard persistentContainer.managedObjectModel.entities.contains(where: { $0.name == entityName }) else {
            debugPrint("⚠️ 삭제하려는 엔티티 '\(entityName)'가 존재하지 않습니다.")
            return
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
            debugPrint("✅ \(entityName) 데이터 삭제 완료")
        } catch {
            debugPrint("❌ \(entityName) 삭제 실패: \(error)")
        }
    }

    
    /// CoreData에 저장완료하는 코드를 간소화하기 위해 만든 함수
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
