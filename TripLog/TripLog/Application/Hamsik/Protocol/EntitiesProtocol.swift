//
//  EntitiesProtocol.swift
//  TripLog
//
//  Created by 황석현 on 1/23/25.
//

import Foundation
import CoreData

protocol CoreDataManagable: AnyObject {
    associatedtype Model
    associatedtype Entity: NSManagedObject
    
    func save(_ data: Any, context: NSManagedObjectContext)
    static func fetch(context: NSManagedObjectContext, predicate: NSPredicate?) -> [Entity]
}
