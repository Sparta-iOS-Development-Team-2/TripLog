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
    /// ModalViewManager.showModal(on: self, state: .editBudget(data: data))
    ///     .subscribe(onNext: { _ in
    ///         print("Completed")
    ///     }).disposed(by: disposeBag)
    /// ```
    ///
    /// ``ModalViewState``
    static func showModal(on view: UIViewController, state: ModalViewState) -> Observable<Void> {
        let modalVC = ModalViewController(state: state)
        view.present(modalVC, animated: true)
        
        return modalVC.rx.completedLogic.asObservable()
    }
    
}
