//
//  NetworkManager.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import CoreData
import UIKit

class CoreDataManager {
    
    static var shared = CoreDataManager()
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
    
    
    /// 특정 Entity를 삭제하는 함수
    /// - Parameter object: 삭제할 하나의 Entity
    ///
    /// 전체 엔티티가 아닌 입력한 하나의 Entity 삭제됩니다.
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
    
    func removeAll() {
        let entitys = persistentContainer.managedObjectModel.entities.map{ $0.name ?? "" }
        
        for entity in entitys {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                saveContext()
                debugPrint("\(entity) 데이터 삭제 완료")
            } catch {
                print("\(entity) 삭제 실패: \(error)")
            }
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
