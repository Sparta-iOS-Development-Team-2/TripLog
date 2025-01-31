//
//  FireStoreManager.swift
//  TripLog
//
//  Created by 황석현 on 1/31/25.
//

import Foundation
import FirebaseFirestore

class FireStoreManager {
    static let shared = FireStoreManager()
    private init() {}
    
    /// FireStore 인스턴스
    let db = Firestore.firestore()
    
    /// 환율정보 생성(API 요청)
    func generateCurrencyRate(date: String) {
        
        APIManager.shared.fetchCurrencyRatesWithAlamofire(dataType: APIInfo.exchangeRate, date: date) { result in
            switch result {
            case .success(let currencyRates):
                self.saveCurrencyToFirestore(data: currencyRates, date: date)
            case .failure(let error):
                print("🔥 Alamofire 통신 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 환율정보 저장(FireStore)
    private func saveCurrencyToFirestore(data: CurrencyRate, date: String = "20250101") {
        let db = Firestore.firestore()
        let dbRef = db.collection("Currency")
        do {
            let encodedData: Data = try JSONEncoder().encode(data)
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                let dataToStore: [String: Any] = ["CurrencyRate": jsonString]
                
                dbRef.document(date).setData(dataToStore) { error in
                    if let error = error {
                        print("🔥 Firestore 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ Firestore 저장 성공! 전체 환율 데이터가 JSON으로 저장됨.")
                    }
                }
            }
        } catch {
            print("🔥 JSON Encoding 실패: \(error.localizedDescription)")
        }
    }
    
    // TODO: 환율정보 검색(추후 추가)
    
}
