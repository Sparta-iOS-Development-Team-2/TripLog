//
//  ModalViewState.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import Foundation

/// 모달 뷰의 상태를 정의하는 enum
enum ModalViewState {
    case createNewCashBook
    case editCashBook(data: TestCashBookData) // 가계부 수정시 데이터 입력
    case createNewbudget
    case editBudget(data: TestModalViewData) // 지출 내역 수정 시 데이터 입력
    
    /// 각 상태에 따라 모달 뷰의 타이틀을 결정하는 프로퍼티
    var modalTitle: String {
        switch self {
        case .createNewCashBook:
            return "새 가계부 만들기"
        case .editCashBook:
            return "가계부 수정하기"
        case .createNewbudget:
            return "새 지출내역 추가하기"
        case .editBudget:
            return "지출내역 수정하기"
        }
    }
}
