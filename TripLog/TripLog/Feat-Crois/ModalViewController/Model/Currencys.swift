//
//  Currencys.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import Foundation

/// 나라별 통화코드(총 26개국)
///
/// - AED (아랍에미리트 디르함)
/// - AUD (호주 달러)
/// - BHD (바레인 디나르)
/// - BND (브루나이 달러)
/// - CAD (캐나다 달러)
/// - CHF (스위스 프랑)
/// - CNH (중국 위안)
/// - DKK (덴마크 크로네)
/// - EUR (유로)
/// - GBP (영국 파운드)
/// - HKD (홍콩 달러)
/// - IDR (인도네시아 루피아)
/// - JPY (일본 엔)
/// - KRW (한국 원)
/// - KWD (쿠웨이트 디나르)
/// - MYR (말레이시아 링기트)
/// - NOK (노르웨이 크로네)
/// - NZD (뉴질랜드 달러)
/// - SAR (사우디 리얄)
/// - SEK (스웨덴 크로나)
/// - SGD (싱가포르 달러)
/// - THB (태국 바트)
/// - USD (미국 달러)
enum Currency: String, CaseIterable {
    case AED = "AED(아랍에미리트 디르함)"
    case AUD = "AUD(호주 달러)"
    case BHD = "BHD(바레인 디나르)"
    case BND = "BND(브루나이 달러)"
    case CAD = "CAD(캐나다 달러)"
    case CHF = "CHF(스위스 프랑)"
    case CNH = "CNH(중국 위안)"
    case DKK = "DKK(덴마크 크로네)"
    case EUR = "EUR(유로)"
    case GBP = "GBP(영국 파운드)"
    case HKD = "HKD(홍콩 달러)"
    case IDR = "IDR(인도네시아 루피아)"
    case JPY = "JPY(일본 엔)"
    case KRW = "KRW(한국 원)"
    case KWD = "KWD(쿠웨이트 디나르)"
    case MYR = "MYR(말레이시아 링기트)"
    case NOK = "NOK(노르웨이 크로네)"
    case NZD = "NZD(뉴질랜드 달러)"
    case SAR = "SAR(사우디 리얄)"
    case SEK = "SEK(스웨덴 크로나)"
    case SGD = "SGD(싱가포르 달러)"
    case THB = "THB(태국 바트)"
    case USD = "USD(미국 달러)"

    // 모든 케이스의 배열 제공
    static var allCurrencies: [String] {
        return Self.allCases.reversed().map { $0.rawValue }
    }
}
