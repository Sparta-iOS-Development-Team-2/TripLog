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
        case result
        case curUnit = "cur_unit"
        case ttb, tts
        case dealBasR = "deal_bas_r"
        case bkpr
        case yyEfeeR = "yy_efee_r"
        case tenDDEfeeR = "ten_dd_efee_r"
        case kftcBkpr = "kftc_bkpr"
        case kftcDealBasR = "kftc_deal_bas_r"
        case curNm = "cur_nm"
    }
}

typealias CurrencyRate = [CurrencyRateElement]
