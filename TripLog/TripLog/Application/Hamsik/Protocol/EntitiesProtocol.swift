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
    
    // 엔티티별 저장로직
    static func save(_ data: Model, context: NSManagedObjectContext)
    // 엔티티별 검색로직
    static func fetch(context: NSManagedObjectContext) -> [Entity]
}
