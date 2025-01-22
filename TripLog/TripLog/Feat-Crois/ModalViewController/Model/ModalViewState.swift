//
//  ModalViewState.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import Foundation

enum ModalViewState {
    case createNewCashBook
    case createNewbudget
    case editBudget(data: TestModalViewData)
    
    var modalTitle: String {
        switch self {
        case .createNewCashBook:
            return "새 가계부 만들기"
        case .createNewbudget:
            return "새 지출내역 추가하기"
        case .editBudget:
            return "지출내역 수정하기"
        }
    }
}
