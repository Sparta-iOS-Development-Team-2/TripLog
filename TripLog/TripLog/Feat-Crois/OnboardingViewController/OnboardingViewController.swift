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
    
    // MARK: - UI Components
    
    fileprivate let onboardingView = OnboardingView()
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .CustomColors.Accent.blue
        $0.pageIndicatorTintColor = .CustomColors.Accent.blue.withAlphaComponent(0.5)
        $0.backgroundColor = .clear
        $0.currentPage = 0 // 초기값 세팅
        $0.numberOfPages = 3 // 최대 페이지 수
    }
    
    // MARK: - OnboardingViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view = onboardingView
        setupPageControl()
        bind()
    }
    
}

// MARK: - UI Setting Method

private extension OnboardingViewController {
    
    func setupPageControl() {
        view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
    }
    
    func bind() {
        onboardingView.rx.leftSwipeAction
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, index in
                owner.onboardingView.changeCurrentPage()
                owner.pageControl.currentPage = index
            }.disposed(by: disposeBag)
        
        onboardingView.rx.rightSwipeAction
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, index in
                owner.onboardingView.changeCurrentPage()
                owner.pageControl.currentPage = index
            }.disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: OnboardingViewController {
    /// "시작하기" 버튼의 탭 이벤트를 방출하는 메소드
    var activeButtonTapped: ControlEvent<Void> {
        base.onboardingView.rx.activeButtonTapped
    }
}
