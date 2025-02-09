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

    private let mainVC = CustomTabBarController()
    
    // MARK: - UI Compnents
    
    private lazy var lottieAnimationView = LottieAnimationView(name: "triplog").then {
        $0.alpha = 1
        $0.loopMode = .repeat(3) // 애니메이션 재생 횟수
    }
    
    private lazy var launchImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "launchImage")
        $0.alpha = 1
    }
    
    private let launchTitle = UILabel().then {
        $0.text = "TripLog"
        $0.textColor = .white
        $0.font = .SCDream(size: .title, weight: .bold)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.alpha = 1
    }
    
    // MARK: - MainViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - UI Setting Method
private extension MainViewController {
    
    func setupUI() {
        // TabBarController 삽입
        addChild(mainVC)
        view.addSubview(mainVC.view)
        mainVC.didMove(toParent: self)
        
        configureSelf()
        setupLayout()
        playLottie()
    }
    
    func configureSelf() {
        navigationItem.title = ""
        [launchImageView,
         lottieAnimationView,
         launchTitle
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayout() {
        launchImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        lottieAnimationView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(self.view.bounds.height)
            $0.bottom.equalToSuperview().inset(50)
        }
        
        launchTitle.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
        }
    }
    
    /// 메인뷰에 온보딩 뷰를 설정하는 메소드
    func setupOnboardingView() {
        let onboardingVC = OnboardingViewController()
        addChild(onboardingVC)
        view.addSubview(onboardingVC.view)
        
        onboardingVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        onboardingVC.didMove(toParent: self)
        
        onboardingVC.rx.activeButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    onboardingVC.view.alpha = 0
                }) { _ in
                    onboardingVC.removeFromParent()
                    onboardingVC.view.removeFromSuperview()
                }
                // "시작하기" 버튼을 눌렀는지 여부로 첫 실행 여부 판정
                UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            }.disposed(by: disposeBag)
    }
    
    /// 온보딩뷰를 보여주는 메소드
    func showOnboardingView() {
        // 처음으로 앱을 실행한 유저인 경우에만 보여줌
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        guard isFirstLaunch else { return }
        
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.setupOnboardingView()
        }
    }
    
    /// Lottie 애니메이션 실행 메소드
    func playLottie() {
        lottieAnimationView.play { [weak self] _ in
            guard let self else { return }
            
            // lottie 애니메이션 재생 완료 후 동작
            UIView.animate(withDuration: 0.3, animations: {
                [self.lottieAnimationView,
                 self.launchImageView,
                 self.launchTitle
                ].forEach { $0.alpha = 0 }
                
                self.showOnboardingView()
                
            // view 애니메이션 종료 후 동작
            }, completion: { _ in
                [self.lottieAnimationView,
                 self.launchImageView,
                 self.launchTitle
                ].forEach {
                    $0.isHidden = true
                    $0.removeFromSuperview()
                    $0.snp.removeConstraints()
                }
            })
        }
    }
}
