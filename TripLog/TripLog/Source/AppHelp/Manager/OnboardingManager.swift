//
//  OnboardingManager.swift
//  TripLog
//
//  Created by 장상경 on 2/18/25.
//

import UIKit
import RxSwift
import RxCocoa

enum OnboardingManager {
    
    static func showOnboardingView() -> Observable<UIViewController> {
        guard let vc = AppHelpers.getTopViewController() else {
            return .error(NSError(domain: "no top viewcontroller", code: -1))
        }
        
        let onboardingVC = OnboardingViewController()
        onboardingVC.view.alpha = 0
        
        vc.addChild(onboardingVC)
        vc.view.addSubview(onboardingVC.view)
        
        onboardingVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        onboardingVC.didMove(toParent: vc)
        
        UIView.animate(withDuration: 0.3) {
            onboardingVC.view.alpha = 1
        }
        
        let dismissSignal = onboardingVC.rx.deallocated
        
        return onboardingVC.rx.activeButtonTapped.map { onboardingVC }.take(until: dismissSignal)
    }
    
}
