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
    var rateDate: String?  // Firestore 문서의 documentID로 할당할 속성(환율날짜)
    
    enum CodingKeys: String, CodingKey {
        case result
        case curUnit = "cur_unit"
        case curNm = "cur_nm"
        case dealBasR = "deal_bas_r"
        case ttb, tts, bkpr
        case yyEfeeR = "yy_efee_r"
        case tenDDEfeeR = "ten_dd_efee_r"
        case kftcBkpr = "kftc_bkpr"
        case kftcDealBasR = "kftc_deal_bas_r"
    }

    // 커스텀 이니셜라이저 추가
    // rateDate(환율날짜)는 문서이름으로써 문서 외의 데이터라 디코딩 과정에서 대입이 불가능
    // 추후 CoreData에 저장할 때 할당 예정이라 현 코드에서 nil을 대입하기 위해
    // 이니셜라이저를 추가하였음.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.result = try container.decodeIfPresent(Int.self, forKey: .result)
        self.curUnit = try container.decodeIfPresent(String.self, forKey: .curUnit)
        self.curNm = try container.decodeIfPresent(String.self, forKey: .curNm)
        self.dealBasR = try container.decodeIfPresent(String.self, forKey: .dealBasR)
        self.ttb = try container.decodeIfPresent(String.self, forKey: .ttb)
        self.tts = try container.decodeIfPresent(String.self, forKey: .tts)
        self.bkpr = try container.decodeIfPresent(String.self, forKey: .bkpr)
        self.yyEfeeR = try container.decodeIfPresent(String.self, forKey: .yyEfeeR)
        self.tenDDEfeeR = try container.decodeIfPresent(String.self, forKey: .tenDDEfeeR)
        self.kftcBkpr = try container.decodeIfPresent(String.self, forKey: .kftcBkpr)
        self.kftcDealBasR = try container.decodeIfPresent(String.self, forKey: .kftcDealBasR)
        
        // nil로 할당
        self.rateDate = nil
    }
}


typealias CurrencyRate = [CurrencyRateElement]
