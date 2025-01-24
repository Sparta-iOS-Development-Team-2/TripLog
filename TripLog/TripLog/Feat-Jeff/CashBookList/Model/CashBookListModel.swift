//
//  CashBookListModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/21/25.
//
import Foundation
import RxDataSources

/// Core Data의 엔티티를 기반으로 하는 가계부 데이터 모델
/// - RxDataSource와 View에서 사용하기 위해 변환된 데이터 모델
/// - 추후 identity의 사용 여부 고려(코어데이터의 NSManagedObjectID)
struct ListCellData: Hashable, IdentifiableType {
    /* 추후 코어데이터로 변경시 적용 예정
    typealias Identity = UUID
    var identity: Identity { UUID() }
     */
    
    var identity = UUID()
    let tripName: String
    let note: String
    let buget: Double
    let departure: String
    let homecoming: String
}

/// RxDataSource에서 사용되는 모델
struct SectionOfListCellData {
    // 섹션이 필요는 없지만 RxDataSource에서 필요로 할 수 있다
    var identity: UUID
    var items: [ListCellData]
}

extension SectionOfListCellData: AnimatableSectionModelType {
    typealias Item = ListCellData
    
    init(original: SectionOfListCellData, items: [ListCellData]) {
        self = original
        self.items = items
    }
}
