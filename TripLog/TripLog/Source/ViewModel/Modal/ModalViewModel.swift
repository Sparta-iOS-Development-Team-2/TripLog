//
//  ModalViewModel.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxKeyboard

/// 모달 뷰 컨트롤러의 비즈니스 로직 담당 뷰 모델
final class ModalViewModel: ViewModelType {
    
    struct Input {
        let cancelButtonTapped: PublishRelay<Void>
        let cashBookActiveButtonTapped: PublishRelay<ModalView.ModalCashBookData>
        let consumptionActiveButtonTapped: PublishRelay<ModalView.ModalConsumptionData>
        let sectionIsEmpty: Observable<Bool>
        let categoryButtonTapped: PublishRelay<String>
    }
    
    struct Output {
        let modalDismiss: PublishRelay<Void>
        let cashBookActive: PublishRelay<(Bool, ModalView.ModalCashBookData)>
        let consumptionActive: PublishRelay<(Bool, ModalView.ModalConsumptionData)>
        let categoryViewDismissed: PublishRelay<String>
    }
    
    let disposeBag = DisposeBag()
    
    private var keyboardHeight: CGFloat = 0
    
    private let modalDismiss = PublishRelay<Void>()
    private let cashBookActive = PublishRelay<(Bool, ModalView.ModalCashBookData)>()
    private let consumptionActive = PublishRelay<(Bool, ModalView.ModalConsumptionData)>()
    private let showCategoryModal = PublishRelay<String>()
    
    private var ModelSectionIsEmpty: Bool?
    
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
                
                guard let isEmpty = owner.ModelSectionIsEmpty else { return }
                owner.cashBookActive.accept((isEmpty, data))
                
            }.disposed(by: disposeBag)
        
        input.consumptionActiveButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                
                guard let isEmpty = owner.ModelSectionIsEmpty else { return }
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
                
                owner.ModelSectionIsEmpty = isEmpty
                
            }.disposed(by: disposeBag)
        
        input.categoryButtonTapped
            .withUnretained(self)
            .flatMap { owner, category in
                owner.showCategoryModal(category)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] category in
                self?.showCategoryModal.accept(category)
            }
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive { [weak self] instanceHeight in
                self?.keyboardHeight = instanceHeight
            }.disposed(by: disposeBag)
        
        return Output(
            modalDismiss: self.modalDismiss,
            cashBookActive: self.cashBookActive,
            consumptionActive: self.consumptionActive,
            categoryViewDismissed: self.showCategoryModal
        )
    }
    
    private func showCategoryModal(_ category: String) -> Observable<String> {
        guard let vc = AppHelpers.getTopViewController(),
              vc as? ModalViewController != nil,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return .error(NSError(domain: "no top view controller", code: -1))
        }
                
        let padding: CGFloat = window.safeAreaInsets.bottom == 0 ? 25 : 0
        
        let categoryVC = CategoryViewController(category)
        let dismissSignal = categoryVC.rx.deallocated.map { _ in "" }
        
        if vc.children.last as? CategoryViewController != nil {
            vc.children.last?.removeFromParent()
        }
        
        vc.addChild(categoryVC)
        vc.view.addSubview(categoryVC.view)
        categoryVC.view.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(vc.view.snp.bottom)
            $0.height.equalTo(190 - padding)
        }
        vc.view.layoutIfNeeded()
        categoryVC.didMove(toParent: vc)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear) {
            categoryVC.view.frame.origin.y -= 190 - padding + self.keyboardHeight
            vc.view.layoutIfNeeded()
        }
        
        return categoryVC.rx.selectedCell.take(until: dismissSignal)
    }
    
}
