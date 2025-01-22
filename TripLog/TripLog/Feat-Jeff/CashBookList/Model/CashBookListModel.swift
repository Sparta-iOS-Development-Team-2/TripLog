//
//  CashBookListModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/21/25.
//
import Foundation
import RxDataSources

/// 가계부 리스트의 데이터 여부 case
enum ListStateSection {
    case emptyState
    case existState
}

/// Core Data의 엔티티를 기반으로 하는 가계부 데이터 모델
/// RxDataSource와 View에서 사용하기 위해 변환된 데이터 모델
struct ListCellData {
    var tripName: String
    var note: String
    var buget: Double
    var departure: String // 추후 date
    var homecoming: String // 추후 date
}

/// RxDataSource에서 사용되는 모델
/// state : section
/// items : item
struct SectionOfListCellData {
    let state: ListStateSection
    var items: [Item]
}

extension SectionOfListCellData: SectionModelType {
    typealias Item = ListCellData
    
    init(original: SectionOfListCellData, items: [Item]) {
        self = original
        self.items = items
    }
}



