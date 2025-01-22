//
//  Currencys.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import Foundation

/// 모든 통화를 모아두는 enum
enum Currency: String, CaseIterable {
    case KRW = "원(한화)"         // 대한민국
    case USD = "USD(달러)"       // 미국
    case EUR = "EUR(유로)"       // 유럽 연합
    case JPY = "JPY(엔)"         // 일본
    case CNY = "CNY(위안)"       // 중국
    case GBP = "GBP(파운드)"     // 영국
    case AUD = "AUD(호주 달러)"  // 호주
    case CAD = "CAD(캐나다 달러)" // 캐나다
    case CHF = "CHF(스위스 프랑)" // 스위스
    case HKD = "HKD(홍콩 달러)"  // 홍콩
    case NZD = "NZD(뉴질랜드 달러)" // 뉴질랜드
    case SGD = "SGD(싱가포르 달러)" // 싱가포르
    case SEK = "SEK(스웨덴 크로나)" // 스웨덴
    case NOK = "NOK(노르웨이 크로네)" // 노르웨이
    case DKK = "DKK(덴마크 크로네)" // 덴마크
    case ZAR = "ZAR(남아프리카 랜드)" // 남아프리카공화국
    case INR = "INR(루피)"       // 인도
    case MYR = "MYR(링깃)"      // 말레이시아
    case IDR = "IDR(루피아)"     // 인도네시아
    case PHP = "PHP(페소)"      // 필리핀
    case THB = "THB(바트)"       // 태국
    case MXN = "MXN(멕시코 페소)" // 멕시코
    case VND = "VND(동)"        // 베트남
    case BRL = "BRL(브라질 헤알)" // 브라질
    case RUB = "RUB(루블)"      // 러시아
    case SAR = "SAR(리얄)"      // 사우디아라비아
    case TRY = "TRY(리라)"      // 터키

    // 모든 케이스의 배열 제공
    static var allCurrencies: [String] {
        return Self.allCases.reversed().map { $0.rawValue }
    }
}
