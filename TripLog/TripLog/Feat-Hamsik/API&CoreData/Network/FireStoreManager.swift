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
    let config: FireStoreConfig
    private init() {
        config = FireStoreConfig()
    }
    
    /// FireStore 인스턴스
    let db = Firestore.firestore()
    
    /// 환율정보 생성(API 요청)
    /// - Parameter date: API에 요청할 환율 날짜
    func generateCurrencyRate(date: String) {
        
        APIManager.shared.fetchCurrencyRatesWithAlamofire(dataType: APIInfo.exchangeRate, date: date) { result in
            switch result {
            case .success(let currencyRates):
                self.saveCurrencyToFirestore(data: currencyRates, date: date)
            case .failure(let error):
                print("Alamofire 통신 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 환율정보 저장(FireStore)
    /// - Parameters:
    ///   - data: 저장할 환율 정보
    ///   - date: 저장할 환율 날짜(= 문서이름)
    private func saveCurrencyToFirestore(data: CurrencyRate, date: String = "20250101") {
        let db = Firestore.firestore()
        let dbRef = db.collection("Currency")
        do {
            let encodedData: Data = try JSONEncoder().encode(data)
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                let dataToStore: [String: Any] = ["CurrencyRate": jsonString]
                
                dbRef.document(date).setData(dataToStore) { error in
                    if let error = error {
                        print("Firestore 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("Firestore 저장 성공! 전체 환율 데이터가 JSON으로 저장됨.")
                    }
                }
            }
        } catch {
            print("JSON Encoding 실패: \(error.localizedDescription)")
        }
    }
    
    
    /// Firestore에 저장된 모든 환율정보 가져오기
    /// - Returns: 모든 환율정보
    func fetchCurrencyFromFirestore() async -> [CurrencyRate] {
        Task {
            let data = try await db.collection("Currency").getDocuments()

            return data
        }
        return []
    }
    
    /// Firestore에 저장된 환율정보 가져오기
    /// - Parameters:
    ///   - date: 조회할 환율 날짜(= 문서이름)
    func getStoreCurrencyRate(date: String, completion: @escaping (CurrencyRate) -> Void) {
        Task {
            let db = Firestore.firestore()
            let docRef = db.collection("Currency").document(date)
            
            do {
                // Firestore의 모든 문서 가져오기
                let document = try await docRef.getDocument()
                
                if let data = document.data(), let currencyRate = data["CurrencyRate"] as? String {
                    // JSON 문자열을 Data 타입으로 변환
                    guard let jsonData = currencyRate.data(using: .utf8) else {
                        print("JSON 문자열을 Data로 변환하는데 실패")
                        return
                    }
                    
                    // JSON 데이터를 CurrencyRate 타입으로 변환
                    do {
                        let decodedRates = try JSONDecoder().decode(CurrencyRate.self, from: jsonData)
                        
                        completion(decodedRates)
                    } catch {
                        print("JSON Decoding 실패: \(error.localizedDescription)")
                    }
                } else {
                    print("Firestore에서 'jsonString' 키를 찾을 수 없음")
                }
            } catch {
                print("Firestore 불러오기 실패: \(error.localizedDescription)")
            }
        }
        
    }
    
    func checkConnection() {
        let db = Firestore.firestore()
        
        db.collection(config.collectionName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Firestore 접근 실패: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                let documents = snapshot.documents
                print("Firestore 연결 성공: 문서 \(documents.count)개")
                
                if let firstDocument = documents.first {
                    print("첫 번째 문서: \(firstDocument.data())")
                } else {
                    print("문서가 없습니다.")
                }
            }
        }
    }
}
