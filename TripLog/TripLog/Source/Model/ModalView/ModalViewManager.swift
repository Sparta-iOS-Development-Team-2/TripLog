//
//  ModalViewManager.swift
//  TripLog
//
//  Created by 장상경 on 1/22/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 모달 뷰와 관련된 전역 메소드를 관리하는 enum
enum ModalViewManager {
    
    /// 모달VC를 present 하는 메소드
    /// - Parameters:
    ///   - view: 모달VC를 present 할 뷰 컨트롤러
    ///   - state: 모달VC의 상태(가계부 추가, 지출 내역 추가, 지출 내역 수정)
    /// - Returns: 모달VC의 active 버튼이 클릭되었다는 이벤트를 방출하는 옵저버블
    ///
    /// - Example
    /// ```swift
    ///  customTabBar.tabBarAddButtonTapped
    ///    .flatMap {
    ///        return ModalViewManager.showModal(state: .createNewCashBook)
    ///            .compactMap { $0 as? CashBookModel }
    ///    }
    ///    .asSignal(onErrorSignalWith: .empty())
    ///    .emit { data in
    ///        CoreDataManager.shared.save(type: CashBookEntity.self, data: data)
    ///    }.disposed(by: disposeBag)
    /// ```
    ///
    /// ``ModalViewState``
    static func showModal(state: ModalViewState) -> Observable<EntityDataSendable> {
        guard let view = AppHelpers.getTopViewController() else {
            return .error(NSError(domain: "No top view controller", code: -1))
        }
        
        let modalVC = ModalViewController(state: state)
        view.present(modalVC, animated: true)
        
        return Observable<EntityDataSendable>.merge(
            modalVC.rx.sendCashBookData.map { $0 as EntityDataSendable },
            modalVC.rx.sendConsumptionData.map { $0 as EntityDataSendable }
        )
    }
    
    static func showCategoryModal(_ model: [String]) -> Observable<String> {
        guard let view = AppHelpers.getTopViewController() else {
            return .error(NSError(domain: "No top view controller", code: -1))
        }
        
        let categoryVC = CategoryViewController(model)
        view.present(categoryVC, animated: true)
        
        return categoryVC.rx.selectedCell.asObservable()
    }
    
}
