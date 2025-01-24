//
//  SettingViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 설정탭 뷰 컨트롤러
final class SettingViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let settingView = SettingView()
    
    // MARK: - UIViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = settingView
        self.navigationController?.navigationBar.isHidden = true
        bind()
    }
    
}

// MARK: - UI Setting Method

private extension SettingViewController {
    
    func bind() {
        sections
            .take(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive(settingView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        settingView.tableView.rx.itemSelected
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, indexPath in
                
                guard
                    let cell = owner.settingView.tableView.cellForRow(at: indexPath) as? SetTableViewCell
                else { return }
                
                guard let toggleSwitch = cell.extraView as? UISwitch else { return }
                if toggleSwitch.isOn {
                    toggleSwitch.setOn(false, animated: true)
                    UserDefaults.standard.set(false, forKey: "isDarkModeEnabled")
                } else {
                    toggleSwitch.setOn(true, animated: true)
                    UserDefaults.standard.set(true, forKey: "isDarkModeEnabled")
                }
                
                cell.action?()
                
            }.disposed(by: disposeBag)
    }
    
}
