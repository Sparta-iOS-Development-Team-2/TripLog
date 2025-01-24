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
    
    // MARK: - Properties
    
    private let viewModel = ModalViewModel()
    
    // MARK: - UI Components
    
    fileprivate let modalView: ModalView
    
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
        self.sheetPresentationController?.detents = [.medium()]
    }
    
    /// 뷰 모델 바인딩 메소드
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

// MARK: - Reactive Extension

extension Reactive where Base: ModalViewController {
    /// 모달뷰의 active 버튼의 tap 이벤트를 방출하는 옵저버블
    var completedLogic: PublishRelay<Void> {
        return base.modalView.rx.activeButtonTapped
    }
}
