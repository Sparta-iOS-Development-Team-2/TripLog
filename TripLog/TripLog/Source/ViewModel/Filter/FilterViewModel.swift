//
//  FilterViewModel.swift
//  TripLog
//
//  Created by jae hoon lee on 2/18/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FilterViewModel: ViewModelType {
    
    /// - selectedPayment : 지출 방법 선택
    /// - selectedCategory : 카테고리 선택
    struct Input {
        let selectedPayment: BehaviorRelay<String>
        let selectedCategory: BehaviorRelay<String>
    }
    /// - selectedPayment : 선택된 지출 방법
    /// - selectedCategory : 선택된 카테고리
    /// - dismissTrigger : 모달 닫기 액션
    struct Output {
        let selectedPayment: BehaviorRelay<String>
        let selectedCategory: BehaviorRelay<String>
        let dismissTrigger: PublishRelay<Void>
    }
    
    // 상태를 관리하는 Relay
    private let selectedPaymentRelay = BehaviorRelay<String>(value: "전체")
    private let selectedCategoryRelay = BehaviorRelay<String>(value: "전체")
    private let dismissTriggerRelay = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    
    /// - parameter :
    ///  - Input: 사용자가 선택한 지출 방법과 카테고리 데이터
    /// - Returns:
    ///  - Output: 선택된 데이터를 포함하는 객체(지출 방법, 카테고리, 모달 닫기 트리거)
    func transform(input: Input) -> Output {
        
        /// 초기에 "전체"로 들어가 있기에 각 섹션이 각각 한 번 이상 선택이 되어야
        /// 닫기 dismissTrigger 실행
        Observable.zip(selectedPaymentRelay.skip(1), selectedCategoryRelay.skip(1))
            .subscribe(onNext: { [weak self] payment, category in
                guard let self = self else { return }
                self.dismissTriggerRelay.accept(())
            }).disposed(by: disposeBag)
        
        // 데이터 전달(behaviorRelay로 저장
        input.selectedPayment
            .bind(to: selectedPaymentRelay)
            .disposed(by: disposeBag)
        
        // 데이터 전달
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)
        
        return Output(selectedPayment: selectedPaymentRelay,
                      selectedCategory: selectedCategoryRelay,
                      dismissTrigger: dismissTriggerRelay
        )
    }
    
}

