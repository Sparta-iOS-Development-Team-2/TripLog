//
//  CoordinatorProtocol.swift
//  TripLog
//
//  Created by 장상경 on 7/17/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var nav: UINavigationController { get set }
    func start()
}
