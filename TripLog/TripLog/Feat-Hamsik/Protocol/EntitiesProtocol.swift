//
//  EntitiesProtocol.swift
//  TripLog
//
//  Created by 황석현 on 1/23/25.
//

import Foundation
import CoreData

protocol CoreDataManagable: NSManagedObject {
    // 데이터 모델
    associatedtype Model
    // 엔티티 타입
    associatedtype Entity = Self
    
    // 엔티티별 저장 로직
    static func save(_ data: Model, context: NSManagedObjectContext)
    // 엔티티별 검색 로직
    static func fetch(context: NSManagedObjectContext, predicate: String?) -> [Entity]
    // 엔티티별 업데이트 로직
    static func update(data: Model, entityID: UUID, context: NSManagedObjectContext)
    // 엔티티별 삭제 로직
    static func delete(entityID: UUID, context: NSManagedObjectContext)
}
