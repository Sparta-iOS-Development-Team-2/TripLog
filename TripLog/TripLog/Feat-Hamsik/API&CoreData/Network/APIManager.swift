//
//  NetworkManager.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import Foundation
import Alamofire

class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
    
    /// API 호출함수
    /// - Parameters:
    ///   - dataType: 검색요청API타입
    ///   - date: 검색 일자
    ///   - completion: 네트워크 요청 시 동작 로직
    func fetchCurrencyRatesWithAlamofire(dataType: String, date: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
        let url = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON"
        let apiKey = APIInfo.apiKey
        let parameters: Parameters = [
            "authkey": apiKey,
            "searchdate": date,
            "data": dataType
        ]
        
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: CurrencyRate.self) { response in
                switch response.result {
                case .success(let currenyRates):
                    completion(.success(currenyRates))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
