//
//  TestSection.swift
//  TripLog
//
//  Created by 김석준 on 2/6/25.
//

import RxDataSources

// ✅ RxDataSources에서 사용할 SectionModel 정의
struct CashBookSection {
    var items: [MockCashBookModel]
}

// ✅ RxDataSources가 `SectionModelType`을 인식하도록 확장
extension CashBookSection: SectionModelType {
    typealias Item = MockCashBookModel

    init(original: CashBookSection, items: [MockCashBookModel]) {
        self = original
        self.items = items
    }
}
