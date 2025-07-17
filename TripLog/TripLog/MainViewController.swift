//
//  ViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/17/25.
//

import UIKit
import Lottie
import SnapKit
import Then
import RxSwift
import RxCocoa

/// TripLog 앱의 메인 뷰 컨트롤러
class MainViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let mainVC: CustomTabBarController
    
    // MARK: - Initializer
    init(coordinator: MainCoordinator) {
        self.mainVC = .init(coordinator: coordinator)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MainViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        Task {
            if CoreDataManager.shared.fetch(type: CurrencyEntity.self).isEmpty {
                do {
                    try await SyncManager.shared.syncCoreDataToFirestore()
                } catch {
                    debugPrint(error)
                }
            } else {
                _ = CoreDataManager.shared.fetch(type: CurrencyEntity.self,
                                                 predicate: Date.formattedDateString(from: Date()))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - UI Setting Method
private extension MainViewController {
    
    func setupUI() {
        addChild(mainVC)
        view.addSubview(mainVC.view)
        mainVC.didMove(toParent: self)
        configureSelf()
        showOnboardingView()
    }
    
    func configureSelf() {
        navigationItem.title = ""
    }
    
    /// 메인뷰에 온보딩 뷰를 설정하는 메소드
    func setupOnboardingView() {
        OnboardingManager.showOnboardingView()
            .asSignal(onErrorSignalWith: .empty())
            .emit { vc in
                UIView.animate(withDuration: 0.3, animations: {
                    vc.view.alpha = 0
                }) { _ in
                    vc.removeFromParent()
                    vc.view.removeFromSuperview()
                }
                // "시작하기" 버튼을 눌렀는지 여부로 첫 실행 여부 판정
                UserDefaults.standard.set(false, forKey: "isFirstLaunch")
            }.disposed(by: disposeBag)
    }
    
    /// 온보딩뷰를 보여주는 메소드
    func showOnboardingView() {
        // 처음으로 앱을 실행한 유저인 경우에만 보여줌
        let isFirstLaunch: Bool
        
        if UserDefaults.standard.object(forKey: "isFirstLaunch") == nil {
            isFirstLaunch = true
        } else {
            isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        }
        
        guard isFirstLaunch else { return }
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.setupOnboardingView()
        }
    }
}
