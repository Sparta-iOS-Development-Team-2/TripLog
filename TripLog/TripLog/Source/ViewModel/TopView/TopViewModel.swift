//
//  TopViewModel.swift
//  TripLog
//
//  Created by 김석준 on 2/6/25.
//

import RxSwift
import RxCocoa

final class TopViewModel {
    let sections = BehaviorRelay<[CashBookSection]>(value: []) // ✅ RxDataSources 바인딩용 데이터
    
    
    private let disposeBag = DisposeBag()
    
    let cashBook: MockCashBookModel

    init(cashBook: MockCashBookModel) {
        // ✅ 단일 여행 정보를 섹션으로 변환하여 RxDataSources에 전달
        let section = CashBookSection(items: [cashBook])
        sections.accept([section])
        self.cashBook = cashBook
    }
}
