//
//  LaunchView.swift
//  TripLog
//
//  Created by 장상경 on 7/17/25.
//

import UIKit
import SnapKit
import Then
import Lottie

final class LaunchViewController: UIViewController {
    
    weak var coordinator: LaunchCoordinator?
    
    private let lottieAnimationView = LottieAnimationView(name: "triplog").then {
        $0.loopMode = .repeat(3) // 애니메이션 재생 횟수
        $0.backgroundColor = .clear
    }
    
    private let launchImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "launchImage")
    }
    
    private let launchTitle = UILabel().then {
        $0.text = "TripLog"
        $0.textColor = .white
        $0.font = .SCDream(size: .title, weight: .bold)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

// MARK: - UI Setting Method

private extension LaunchViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        playLottie()
    }
    
    func configureSelf() {
        [launchImageView,
         lottieAnimationView,
         launchTitle
        ].forEach { view.addSubview($0) }
        view.backgroundColor = .CustomColors.Background.background
    }
    
    func setupLayout() {
        launchImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        lottieAnimationView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(self.view.bounds.height)
            $0.bottom.equalToSuperview().inset(50)
        }
        
        launchTitle.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
        }
    }
    
    /// Lottie 애니메이션 실행 메소드
    func playLottie() {
        lottieAnimationView.play { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.3, animations: {
                [
                    self.lottieAnimationView,
                    self.launchTitle,
                    self.launchImageView
                ].forEach {
                    $0.alpha = 0
                }
                ThemeManager.loadTheme(for: self.view.window)
            }) { _ in
                LottieAnimationCache.shared?.clearCache()
                self.coordinator?.launchCoordinatorDidFinish()
            }
        }
    }
    
}
