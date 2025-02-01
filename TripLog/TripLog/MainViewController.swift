//
//  ViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/17/25.
//

import UIKit

class MainViewController: UIViewController {

    private let mainVC = CustomTabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
    }

    func setupUI() {
        
        addChild(mainVC)
        view.addSubview(mainVC.view)
    }

}

