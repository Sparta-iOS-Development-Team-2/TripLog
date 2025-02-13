//
//  ModalViewModel.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 모달 뷰 컨트롤러의 비즈니스 로직 담당 뷰 모델
final class ModalViewModel: ViewModelType {
    
    struct Input {
        let cancelButtonTapped: PublishRelay<Void>
        let cashBookActiveButtonTapped: PublishRelay<ModalView.ModalCashBookData>
        let consumptionActiveButtonTapped: PublishRelay<ModalView.ModalConsumptionData>
        let sectionIsEmpty: Observable<Bool>
    }
    
    struct Output {
        let modalDismiss: PublishRelay<Void>
        let cashBookActive: PublishRelay<(Bool, ModalView.ModalCashBookData)>
        let consumptionActive: PublishRelay<(Bool, ModalView.ModalConsumptionData)>
    }
    
    let disposeBag = DisposeBag()
    
    private let modalDismiss = PublishRelay<Void>()
    private let cashBookActive = PublishRelay<(Bool, ModalView.ModalCashBookData)>()
    private let consumptionActive = PublishRelay<(Bool, ModalView.ModalConsumptionData)>()
    
    private var textFieldIsEmpty: Bool?
    
    /// input을 output으로 변환해주는 메소드
    /// - Parameter input:
    /// **cancelButtonTapped**: 취소 버튼의 탭 이벤트를 방출하는 옵저버블
    /// **cashBookActiveButtonTapped**: 모달뷰가 가계부 상태일 때 active 버튼의 탭 이벤트를 방출하는 옵저버블
    /// **consumptionActiveButtonTapped**: 모달뷰가 지출 내역 상태일 때 active 버튼의 탭 이벤트를 방출하는 옵저버블
    /// **sectionIsEmpty**: 모달뷰의 섹션 중 빈 값이 있는지 검사하고 이벤트를 방출하는 옵저버블
    ///
    /// - Returns:
    /// **modalDismiss**: 취소 버튼이 눌리면 모달을 닫도록 이벤트를 방출하는 옵저버블
    /// **cashBookActive**: 모달뷰가 가계부 상태일 때 active 버튼을 통해 특정 로직을 실행하도록 이벤트를 방출하는 옵저버블
    /// **consumptionActive**: 모달뷰가 지출 내역 상태일 때 active 버튼을 통해 특정 로직을 실행하도록 이벤트를 방출하는 옵저버블
    func transform(input: Input) -> Output {
        input.cashBookActiveButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                
                guard let isEmpty = owner.textFieldIsEmpty else { return }
                owner.cashBookActive.accept((isEmpty, data))
                
            }.disposed(by: disposeBag)
        
        input.consumptionActiveButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                
                guard let isEmpty = owner.textFieldIsEmpty else { return }
                owner.consumptionActive.accept((isEmpty, data))
                
            }.disposed(by: disposeBag)
        
        input.cancelButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                
                owner.modalDismiss.accept(())
                
            }.disposed(by: disposeBag)
        
        input.sectionIsEmpty
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, isEmpty in
                
                owner.textFieldIsEmpty = isEmpty
                
            }.disposed(by: disposeBag)
        
        return Output(
            modalDismiss: self.modalDismiss,
            cashBookActive: self.cashBookActive,
            consumptionActive: self.consumptionActive
        )
    }
}
