//
//  CashBookListDataSources.swift
//  TripLog
//
//  Created by jae hoon lee on 1/21/25.
//
import Foundation
import RxDataSources

/// RxDataSource에서 사용되는 모델
struct SectionOfListCellData {
    var id: UUID // coredata의 UUID사용 (섹션을 구분)
    var items: [CashBookModel]
}

extension SectionOfListCellData: AnimatableSectionModelType {
    
    typealias Identity = UUID
    typealias Item = CashBookModel
    
    var identity: UUID { id } // coredata의 UUID사용 (dataSource에서 섹션 구분)
    
    init(original: SectionOfListCellData, items: [CashBookModel]) {
        self = original
        self.items = items
    }
}
