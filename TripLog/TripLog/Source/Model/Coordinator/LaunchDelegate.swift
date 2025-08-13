//
//  LaunchDelegate.swift
//  TripLog
//
//  Created by 장상경 on 7/17/25.
//

import Foundation

protocol LaunchDelegate: AnyObject {
    func launchCoordinatorDidFinish(_ coordinator: LaunchCoordinator)
}
