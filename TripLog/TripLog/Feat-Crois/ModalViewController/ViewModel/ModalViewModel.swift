//
//  ModalViewModel.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import RxSwift
import RxCocoa

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
