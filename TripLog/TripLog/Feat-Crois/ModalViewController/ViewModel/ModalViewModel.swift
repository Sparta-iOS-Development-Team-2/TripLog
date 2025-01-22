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
        let activeButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let modalDismiss: PublishRelay<Void>
        let active: PublishRelay<Void>
    }
    
    let disposeBag = DisposeBag()
    
    private let modalDismiss = PublishRelay<Void>()
    private let active = PublishRelay<Void>()
    
    /// input을 output으로 변환해주는 메소드
    /// - Parameter input:
    /// **cancelButtonTapped**: 취소 버튼의 탭 이벤트를 방출하는 옵저버블
    /// **activeButtonTapped**: active 버튼의 탭 이벤트를 방출하는 옵저버블
    ///
    /// - Returns:
    /// **modalDismiss**: 취소 버튼이 눌리면 모달을 닫도록 이벤트를 방출하는 옵저버블
    /// **active**: active 버튼을 통해 특정 로직을 실행하도록 이벤트를 방출하는 옵저버블
    func transform(input: Input) -> Output {
        input.activeButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                
                owner.active.accept(())
                
            }.disposed(by: disposeBag)
        
        input.cancelButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                
                owner.modalDismiss.accept(())
                
            }.disposed(by: disposeBag)
        
        return Output(
            modalDismiss: self.modalDismiss,
            active: self.active
        )
    }
}
