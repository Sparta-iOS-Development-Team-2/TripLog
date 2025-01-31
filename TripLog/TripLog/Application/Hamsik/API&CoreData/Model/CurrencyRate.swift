//
//  ExchangeRate.swift
//  TripLog
//
//  Created by 황석현 on 1/21/25.
//

import Foundation

struct CurrencyRateElement: Codable {
    let result: Int?
    let curUnit, ttb, tts, dealBasR: String?
    let bkpr, yyEfeeR, tenDDEfeeR, kftcBkpr: String?
    let kftcDealBasR, curNm: String?

    enum CodingKeys: String, CodingKey {
        /// API 호출 상태코드
        case result
        /// 통화코드
        case curUnit = "cur_unit"
        /// 국가/통화명
        case curNm = "cur_nm"
        /// 매매 기준율(환율)
        case dealBasR = "deal_bas_r"
        
        
        // 전신환 송금,송신
        case ttb, tts
        // 장부가격
        case bkpr
        // 년환가료율
        case yyEfeeR = "yy_efee_r"
        // 10일환가료율
        case tenDDEfeeR = "ten_dd_efee_r"
        // 서울외국환중개 매매기준율
        case kftcBkpr = "kftc_bkpr"
        // 서울외국환중개 장부가격
        case kftcDealBasR = "kftc_deal_bas_r"
    }
}

typealias CurrencyRate = [CurrencyRateElement]
