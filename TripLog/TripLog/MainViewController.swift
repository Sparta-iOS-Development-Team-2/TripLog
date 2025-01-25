//
//  ViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/17/25.
//

import UIKit
import Lottie
import Then

class MainViewController: UIViewController {
    
    private lazy var animationView = LottieAnimationView(name: "triplog").then {
        $0.frame = view.bounds
        $0.center = view.center
        $0.alpha = 1
    }
    private lazy var image = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.image = UIImage(named: "launchImage")
        $0.frame = view.bounds
        $0.center = view.center
        $0.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

private extension MainViewController {
    
    func setupUI() {
        configureSelf()
        playLottie()
    }
    
    func configureSelf() {
        [image, animationView].forEach { view.addSubview($0) }
    }
    
    func playLottie() {
        animationView.loopMode = .repeat(3)
        animationView.play { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.animationView.alpha = 0
                self.image.alpha = 0
            }, completion: { _ in
                self.animationView.isHidden = true
                self.image.isHidden = true
                self.animationView.removeFromSuperview()
                self.image.removeFromSuperview()
            })
        }
    }
}
