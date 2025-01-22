//
//  ModalViewManager.swift
//  TripLog
//
//  Created by 장상경 on 1/22/25.
//

import UIKit
import RxSwift
import RxCocoa

enum ModalViewManager {
    
    static func showModal(on view: UIViewController, state: ModalViewState) -> Observable<Void> {
        let modalVC = ModalViewController(state: state)
        view.present(modalVC, animated: true)
        
        return modalVC.rx.completedLogic.asObservable()
    }
    
}
