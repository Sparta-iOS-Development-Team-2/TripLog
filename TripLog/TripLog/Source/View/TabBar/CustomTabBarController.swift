//
//  CustomTabBarController.swift
//  TripLog
//
//  Created by jae hoon lee on 1/29/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CustomTabBarController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let customTabBar = TabBarView()
    private let viewModel = CustomTabBarViewModel()
    
    // 텝바에 들어가는 화면 선언
    private let cashBookVC = CashBookListViewController()
    private let settingVC = SettingViewController()
    
    //MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupUIConstraints()
        bind()
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            customTabBar.applyTabBarStyle()
        }
    }
    
}

//MARK: - Private Method
private extension CustomTabBarController {
    
    /// setupUI
    func setupUI() {
        
        view.backgroundColor = UIColor.CustomColors.Background.background
        
        // 탭바 스타일 적용
        customTabBar.applyTabBarStyle()
        
        // 자식 뷰컨트롤러 추가
        addChild(cashBookVC)
        addChild(settingVC)
        
        // 뷰 추가
        view.addSubview(cashBookVC.view)
        view.addSubview(settingVC.view)
        view.addSubview(customTabBar)
        
        // 뷰컨 이동 완료처리
        cashBookVC.didMove(toParent: self)
        settingVC.didMove(toParent: self)
        
        // 첫 화면 cashBookVC으로 표시
        switchToViewController(cashBookVC)
    }
    
    /// setupUIConstraints
    func setupUIConstraints() {
        
        cashBookVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customTabBar.snp.top)
        }
        
        settingVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customTabBar.snp.top)
        }
        
        customTabBar.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
    
    func bind() {
        
        /// Input
        /// - cashBookTapped : 탭바의 가계부 리스트 탭 선택
        /// - settingTapped : 탭바의 설정 탭 선택
        /// - tabBarAddButtonTapped : 탭바의 일정 추가하기 버튼
        let input = CustomTabBarViewModel.Input(
            cashBookTapped: customTabBar.cashBookTapped,
            settingTapped: customTabBar.settingTapped,
            tabBarAddButtonTapped: customTabBar.tabBarAddButtonTapped
        )
        
        /// Output
        /// - currentState : 현재 탭의 상태를 변경(해당 탭 호출, 색상 변경)
        /// - isAddButtonEnable : 새 가계부 추가 모달을 사용
        let output = viewModel.transform(input: input)
        
        output.currentState
            .distinctUntilChanged()
            .drive(onNext: { [weak self] state in
                guard let self = self else {return}
                switch state {
                case .cashBookList :
                    self.switchToViewController(self.cashBookVC)
                case .setting :
                    self.switchToViewController(self.settingVC)
                }
            }).disposed(by: disposeBag)
        
        output.currentState
            .drive(onNext: { [weak self] state in
                self?.customTabBar.updateTabItem(for: state)
            }).disposed(by: disposeBag)
        
        output.isAddButtonEnable
            .drive(customTabBar.tabBarAddButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 탭바의 추가하기 버튼 바인딩
        customTabBar.tabBarAddButtonTapped
            .flatMap {
                return ModalViewManager.showModal(state: .createNewCashBook)
                    .compactMap { $0 as? CashBookModel }
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { data in
                CoreDataManager.shared.save(type: CashBookEntity.self, data: data)
            }.disposed(by: disposeBag)
    }
    
    /// 선택한 탭바의 화면으로 전환 (애니메이션 추가)
    func switchToViewController(_ viewController: UIViewController) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.view.bringSubviewToFront(viewController.view)
            self.view.bringSubviewToFront(self.customTabBar) // 탭바가 항상 위에 있도록 추가
        }, completion: nil)
    }
    
}
