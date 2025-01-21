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

final class ModalViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = ModalViewModel()
    
    private let modalView: ModalView
    
    init(state: ModalViewState) {
        self.modalView = ModalView(state: state)
        super.init(nibName: nil, bundle: nil)
        configureSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = self.modalView
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
}

private extension ModalViewController {
    
    func configureSelf() {
        self.modalPresentationStyle = .formSheet
        self.sheetPresentationController?.preferredCornerRadius = 12
        self.sheetPresentationController?.detents = [.medium()]
    }

    func bind() {
        let input: ModalViewModel.Input = .init(
            cancelButtonTapped: self.modalView.rx.cancelButtonTapped,
            activeButtonTapped: self.modalView.rx.activeButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.active
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                
                switch owner.modalView.checkModalStatus() {
                case .createNewCashBook: break
                    // 가계부를 코어 데이터에 추가하는 로직
                case .createNewbudget: break
                    // 지출 내역을 코어 데이터에 추가하는 로직
                case .editBudget: break
                    // 지출 내역을 코어 데이터에 업데이트 하는 로직
                }
                
                owner.dismiss(animated: true)
                
            }.disposed(by: disposeBag)
        
        output.modalDismiss
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] _ in
                
                self?.dismiss(animated: true)
                
            }.disposed(by: disposeBag)
    }
}

