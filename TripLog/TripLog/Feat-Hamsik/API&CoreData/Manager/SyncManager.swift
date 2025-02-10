//
//  SyncManager.swift
//  TripLog
//
//  Created by 황석현 on 2/10/25.
//

import Foundation

final class SyncManager {
    static let shared = SyncManager()
    
    private init() {}
    
    func syncCoreDataToFirestore() async throws {
        Task {
            do {
                let fireStore = try await FireStoreManager.shared.fetchAllData()
                CoreDataManager.shared.save(type: CurrencyEntity.self, data: fireStore)
            } catch {
                print(error)
            }
        }
    }
}
