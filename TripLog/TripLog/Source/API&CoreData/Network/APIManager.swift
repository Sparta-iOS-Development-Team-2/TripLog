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
    ///   - authKey: API 인증키
    ///   - dataType: 환율 / 대출금리 / 국제금리
    func fetchCurrencyRatesWithAlamofire(dataType: String, date: Date, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
        let url = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON"
        let searchDate = Date.formattedDateString(from: date)
        let apiKey = APIInfo.apiKey
        let parameters: Parameters = [
            "authkey": apiKey,
            "searchdate": searchDate,
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
