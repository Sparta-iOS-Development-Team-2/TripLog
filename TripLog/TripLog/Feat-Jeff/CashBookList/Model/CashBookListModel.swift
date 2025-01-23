//
//  CashBookListModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/21/25.
//
import Foundation
import RxDataSources

/// Core Data의 엔티티를 기반으로 하는 가계부 데이터 모델
/// RxDataSource와 View에서 사용하기 위해 변환된 데이터 모델
struct ListCellData: Equatable, IdentifiableType {
    var identity: UUID
    let tripName: String
    let note: String
    let buget: Double
    let departure: String
    let homecoming: String
    
    init(tripName: String, note: String, buget: Double, departure: String, homecoming: String) {
        self.identity = UUID()
        self.tripName = tripName
        self.note = note
        self.buget = buget
        self.departure = departure
        self.homecoming = homecoming
    }
}

/// RxDataSource에서 사용되는 모델
struct SectionOfListCellData {
    var items: [ListCellData]
    var identity: UUID
}

extension SectionOfListCellData: AnimatableSectionModelType {
    typealias Item = ListCellData
    
    init(original: SectionOfListCellData, items: [ListCellData]) {
        self = original
        self.items = items
    }
}
