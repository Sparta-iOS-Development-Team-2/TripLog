//
//  ModalConsumptionData.swift
//  TripLog
//
//  Created by 장상경 on 2/9/25.
//

import Foundation

/// 모달뷰에서 새 지출내역을 추가할 때 사용할 데이터 타입
struct ModalConsumptionData {
    let cashBookID: UUID
    let date: Date
    let exchangeRate: [CurrencyEntity]
}
