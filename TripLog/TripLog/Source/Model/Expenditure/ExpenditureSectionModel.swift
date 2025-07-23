//
//  TodaySectionModel.swift
//  TripLog
//
//  Created by 김석준 on 2/18/25.
//

import RxDataSources

struct ExpenditureSectionModel {
    var date: String // 섹션의 헤더로 사용할 날짜
    var items: [MyCashBookModel] // 해당 날짜에 속하는 지출 항목
}

extension ExpenditureSectionModel: SectionModelType {
    typealias Item = MyCashBookModel

    init(original: ExpenditureSectionModel, items: [MyCashBookModel]) {
        self = original
        self.items = items
    }
}
