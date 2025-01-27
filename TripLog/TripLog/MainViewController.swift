//
//  ViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/17/25.
//

import UIKit
import Lottie
import Then

/// TripLog 앱의 메인 뷰 컨트롤러
class MainViewController: UIViewController {
    
    // MARK: - UI Compnents
    
    private lazy var lottieAnimationView = LottieAnimationView(name: "triplog").then {
        $0.frame = view.bounds
        $0.center = view.center
        $0.alpha = 1
        $0.loopMode = .repeat(3) // 애니메이션 재생 횟수
    }
    
    private lazy var launchImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "launchImage")
        $0.frame = view.bounds
        $0.center = view.center
        $0.alpha = 1
    }
    
    // MARK: - MainViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - UI Setting Method
private extension MainViewController {
    
    func setupUI() {
        configureSelf()
        playLottie()
    }
    
    func configureSelf() {
        [launchImageView, lottieAnimationView].forEach { view.addSubview($0) }
    }
    
    /// Lottie 애니메이션 실행 메소드
    func playLottie() {
        lottieAnimationView.play { _ in
            // lottie 애니메이션 재생 완료 후 동작
            UIView.animate(withDuration: 0.3, animations: {
                self.lottieAnimationView.alpha = 0
                self.launchImageView.alpha = 0
                
                // view 애니메이션 종료 후 동작
            }, completion: { _ in
                self.lottieAnimationView.isHidden = true
                self.launchImageView.isHidden = true
                self.lottieAnimationView.removeFromSuperview()
                self.launchImageView.removeFromSuperview()
            })
        }
    }
}
