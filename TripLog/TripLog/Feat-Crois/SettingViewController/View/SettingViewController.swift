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
    
    private let disposeBag = DisposeBag()
    
    private let settingView = SettingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = settingView
        self.navigationController?.navigationBar.isHidden = true
        bind()
    }
    
}

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
                
                cell.action?()
                
            }.disposed(by: disposeBag)
    }
    
}
