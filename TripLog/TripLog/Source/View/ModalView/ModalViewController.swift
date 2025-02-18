//
//  ModalViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달뷰 컨트롤러
final class ModalViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    fileprivate let cashBookActiveButtonTapped = PublishRelay<CashBookModel>()
    fileprivate let consumptionActiveButtonTapped = PublishRelay<MyCashBookModel>()
    
    // MARK: - Properties
    
    private let viewModel = ModalViewModel()
    
    // MARK: - UI Components
    
    private let modalView: ModalView
    
    // MARK: - Initializer
    
    /// 모달 뷰 컨트롤러의 기본 생성자
    /// - Parameter state: 모달뷰의 state
    ///
    /// ``ModalViewState``
    init(state: ModalViewState) {
        self.modalView = ModalView(state: state)
        super.init(nibName: nil, bundle: nil)
        configureSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = self.modalView
        bind()
    }
    
    // 뷰 컨트롤러 영역에서 터치 이벤트가 발생하면 editing 모드를 종료
    // 키보드를 내리기 위한 메소드 재정의
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layer.shadowPath = self.view.shadowPath()
    }

}

// MARK: - UI Setting Method

private extension ModalViewController {
    
    func configureSelf() {
        self.modalPresentationStyle = .formSheet
        self.sheetPresentationController?.preferredCornerRadius = 12
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in 464 })]
        self.sheetPresentationController?.prefersGrabberVisible = true
    }
    
    /// 뷰 모델 바인딩 메소드
    func bind() {
        
        let input: ModalViewModel.Input = .init(
            cancelButtonTapped: self.modalView.rx.cancelButtonTapped,
            cashBookActiveButtonTapped: self.modalView.rx.cashBookActiveButtonTapped,
            consumptionActiveButtonTapped: self.modalView.rx.consumptionActiveButtonTapped,
            sectionIsEmpty: self.modalView.rx.checkBlankOfSections,
            categoryButtonTapped: self.modalView.rx.categoryButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.cashBookActive
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                
                guard !data.0 else {
                    let alert = AlertManager(title: "알림", message: "모든 내용을 정확히 입력해주세요", cancelTitle: "확인")
                    alert.showAlert(.alert)
                    return
                }
                
                let cashBookData = CashBookEntity.Model(id: data.1.id,
                                                        tripName: data.1.tripName,
                                                        note: data.1.note,
                                                        budget: data.1.budget,
                                                        departure: data.1.departure,
                                                        homecoming: data.1.homecoming)
                
                owner.cashBookActiveButtonTapped.accept(cashBookData)
                owner.dismiss(animated: true)
                
            }.disposed(by: disposeBag)
        
        output.consumptionActive
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                
                guard !data.0 else {
                    let alert = AlertManager(title: "알림", message: "모든 내용을 정확히 입력해주세요", cancelTitle: "확인")
                    alert.showAlert(.alert)
                    return
                }
                
                let consumptionData = MyCashBookEntity.Model(amount: data.1.amount,
                                                             cashBookID: data.1.cashBookID,
                                                             caculatedAmount: data.1.exchangeRate,
                                                             category: data.1.category,
                                                             country: data.1.country,
                                                             expenseDate: data.1.expenseDate,
                                                             id: data.1.id,
                                                             note: data.1.note,
                                                             payment: data.1.payment)
                
                owner.consumptionActiveButtonTapped.accept(consumptionData)
                owner.dismiss(animated: true)
                
            }.disposed(by: disposeBag)
        
        output.modalDismiss
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        output.categoryViewDismissed
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, category in
                owner.modalView.configureCategoryView(category)
            }.disposed(by: disposeBag)
        
    }

}

// MARK: - Reactive Extension

extension Reactive where Base: ModalViewController {
    /// 모달뷰에서 입력된 가계부 정보를 전달하는 옵저버블
    var sendCashBookData: PublishRelay<CashBookModel> {
        return base.cashBookActiveButtonTapped
    }
    
    // 모달뷰에서 입력된 지출 정보를 전달하는 옵저버블
    var sendConsumptionData: PublishRelay<MyCashBookModel> {
        return base.consumptionActiveButtonTapped
    }
}

// 사용하는 뷰컨트롤러에 추가를 해주셔야 popover기능을 아이폰에서 정상적으로 사용 가능합니다.
extension ModalViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
