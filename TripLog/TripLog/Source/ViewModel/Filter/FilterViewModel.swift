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
    struct Input {
        let selectedPayment: PublishRelay<String>
        let selectedCategory: PublishRelay<String>
    }
    
    struct Output {
        let selectedPayment: BehaviorRelay<String>
        let selectedCategory: BehaviorRelay<String>
        let dismissTrigger: PublishRelay<Void>
    }
    
    private let selectedPaymentRelay = BehaviorRelay<String>(value: "전체")
    private let selectedCategoryRelay = BehaviorRelay<String>(value: "전체")
    private let dismissTriggerRelay = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        Observable.zip(selectedPaymentRelay.skip(1), selectedCategoryRelay.skip(1))
            .subscribe(onNext: { [weak self] payment, category in
                guard let self = self else { return }
                self.dismissTriggerRelay.accept(())
            }).disposed(by: disposeBag)
        
        input.selectedPayment
            .bind(to: selectedPaymentRelay)
            .disposed(by: disposeBag)
        
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)
        
        return Output(selectedPayment: selectedPaymentRelay,
                      selectedCategory: selectedCategoryRelay,
                      dismissTrigger: dismissTriggerRelay
        )
    }
    
}

