//
//  MainViewController.swift
//  TripLog
//
//  Created by jae hoon lee on 1/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: CustomTabBarController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        bind()
    }

    private func setupViewHierarchy() {
        // 1️⃣ 자식 뷰컨트롤러를 부모 뷰에 추가
        addChild(cashBookVC)
        addChild(settingsVC)

        view.addSubview(cashBookVC.view)
        view.addSubview(settingsVC.view)
        view.addSubview(customTabBar)

        cashBookVC.didMove(toParent: self)
        settingsVC.didMove(toParent: self)

        // 2️⃣ 레이아웃 설정
        cashBookVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customTabBar.snp.top)
        }

        settingsVC.view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customTabBar.snp.top)
        }

        customTabBar.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // ✅ Safe Area 활용
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80) // ✅ 고정 높이 설정
        }

        // 3️⃣ 앱 시작 시 cashBookVC가 보이도록 설정
        view.bringSubviewToFront(cashBookVC.view)
    }

    private func bind() {
        // 📌 가계부 버튼 클릭 시 cashBookVC 앞으로 가져옴
        customTabBar.cashBookTapped
            .bind(with: self) { ss, _ in
                ss.switchToViewController(ss.cashBookVC)
            }
            .disposed(by: disposeBag)

        // 📌 설정 버튼 클릭 시 settingsVC 앞으로 가져옴
        customTabBar.settingTapped
            .bind(with: self) { ss, _ in
                ss.switchToViewController(ss.settingsVC)
            }
            .disposed(by: disposeBag)
    }

    private func switchToViewController(_ viewController: UIViewController) {
        view.bringSubviewToFront(viewController.view)
        view.bringSubviewToFront(customTabBar) // ✅ 탭바가 항상 위에 있도록 추가
    }
}
