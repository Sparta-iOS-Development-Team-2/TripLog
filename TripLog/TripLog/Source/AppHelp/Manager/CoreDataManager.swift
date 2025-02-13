//
//  NetworkManager.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import CoreData
import UIKit

/// CoreData 저장, 로드관련 매니져
final class CoreDataManager {
    
    static var shared: CoreDataManager!
    let persistentContainer: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Functions for CoreData
    
    /// CoreData에 Entity를 저장하는 함수
    /// - Parameters:
    ///   - type: 저장할 Entity 타입(예: CashEntity.self)
    ///   - data: 저장할 데이터(예: CashBookModel)
    func save<T: CoreDataManagable>(type: T.Type, data: T.Model) {
        T.save(data, context: context)
    }
    
    /// CoreData에 저장된 Entity를 불러오는 함수
    /// - Parameters:
    ///   - type: 불러올 Entity 타입(예: CashEntity.self)
    ///   - predicate: 검색할 특정 문자
    ///   (예: let predicate = NSPredicate(format: "tripName CONTAINS[cd] %@", "trip1"))
    /// - Returns: 검색결과
    func fetch<T: CoreDataManagable>(type: T.Type, predicate: Any? = nil) -> [T.Entity] {
        return type.fetch(context: context, predicate: predicate)
    }
    
    /// CoreData에 저장된 Entity를 수정(업데이트)하는 함수
    /// - Parameters:
    ///   - type: 업데이트할 Entity의 Type(예: CashBookEntity.self)
    ///   - entityID: 업데이트할 Entity의 ID
    ///   - data: 업데이트할 Entity의 Data
    func update<T: CoreDataManagable>(type: T.Type, entityID: UUID, data: T.Model) {
        T.update(data: data, entityID: entityID, context: context)
    }
    
    /// CoreData에 저장된 Entity를 삭제하는 함수
    /// - Parameters:
    ///   - type: 삭제할 Entity의 Type(예: CashBookEntity.self)
    ///   - entityID: 삭제할 Entity의 ID
    func delete<T: CoreDataManagable>(type: T.Type, entityID: UUID? = nil) {
        T.delete(entityID: entityID, context: context)
    }
}
