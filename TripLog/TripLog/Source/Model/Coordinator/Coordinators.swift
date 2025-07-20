//
//  Coordinators.swift
//  TripLog
//
//  Created by 장상경 on 7/17/25.
//

import UIKit

// MARK: - AppCoordinator

/// 앱 전체의 화면을 관리하는 코디네이터
final class AppCoordinator: Coordinator {
    private var childCoordinators: [Coordinator] = []
    var nav: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    func start() {
        let coordinator = LaunchCoordinator(nav)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

// 런치화면 델리게이트 메소드
extension AppCoordinator: LaunchDelegate {
    
    func launchCoordinatorDidFinish(_ coordinator: LaunchCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        
        let mainCoordinator = MainCoordinator(nav)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
    
}

// MARK: - LaunchCoordinator

final class LaunchCoordinator: Coordinator {
    var nav: UINavigationController
    weak var delegate: LaunchDelegate?
    
    init(_ navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    func start() {
        let vc = LaunchViewController()
        vc.coordinator = self
        nav.viewControllers = [vc]
    }
    
    func launchCoordinatorDidFinish() {
        delegate?.launchCoordinatorDidFinish(self)
    }
}

// MARK: - MainCoordinator

final class MainCoordinator: Coordinator {
    var nav: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.nav = navigationController
    }
    
    func start() {
        let vc = MainViewController(coordinator: self)
        nav.viewControllers = [vc]
    }
    
    func pushDetailViewController(_ item: CashBookModel) {
        let vc = CashBookDetailViewController(cashBook: item)
        nav.pushViewController(vc, animated: true)
    }
}
