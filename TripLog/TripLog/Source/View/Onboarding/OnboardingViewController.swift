//
//  OnboardingViewController.swift
//  TripLog
//
//  Created by 장상경 on 2/9/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

/// 온보딩 뷰를 관리하는 뷰 컨트롤러
final class OnboardingViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    fileprivate let active = PublishRelay<Void>()
    
    // MARK: - UI Components
    
    fileprivate lazy var onboardingView = OnboardingView()
    
    // MARK: - OnboardingViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view = onboardingView
        bind()
    }
    
}

// MARK: - UI Setting Method

private extension OnboardingViewController {
    
    func bind() {
        onboardingView.rx.leftSwipeAction
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.onboardingView.changeCurrentPage()
            }.disposed(by: disposeBag)
        
        onboardingView.rx.rightSwipeAction
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.onboardingView.changeCurrentPage()
            }.disposed(by: disposeBag)
        
        onboardingView.rx.activeButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, index in
                owner.onboardingView.changePageInDirection(.left)
                owner.onboardingView.changeCurrentPage()
                guard index == 2 else { return }
                owner.active.accept(())
            }.disposed(by: disposeBag)
        
        onboardingView.rx.skipButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(to: active)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: OnboardingViewController {
    /// "시작하기" 버튼의 탭 이벤트를 방출하는 메소드
    var activeButtonTapped: PublishRelay<Void> {
        base.active
    }
}
