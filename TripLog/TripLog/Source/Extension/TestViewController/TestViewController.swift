//
//  ViewController.swift
//  TripLog
//
//  Created by 장상경 on 1/17/25.
//

import UIKit
import SnapKit

class TestViewController: UIViewController {
    // MARK: - UI Components
    private lazy var boxTestView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyBoxStyle()
        return view
    }()
    
    private lazy var tabBarTestView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyTabBarStyle()
        return view
    }()
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.CustomColors.Accent.blue
        button.applyFloatingButtonStyle()
        button.setTitle("Floating", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var testTextField: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyTextFieldStyle()
        return view
    }()
    
    private lazy var testButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.applyButtonStyle()
        button.setTitle("Test Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var viewStyleTest: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyViewStyle()
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateShadowPaths()
        setupUI()
    }
    
    // viewDidLayoutSubviews 추가
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShadowPaths()
    }

    // 그림자 경로 업데이트를 위한 함수 추가
    private func updateShadowPaths() {
        boxTestView.layer.shadowPath = boxTestView.shadowPath()
        tabBarTestView.layer.shadowPath = tabBarTestView.shadowPath()
        floatingButton.layer.shadowPath = floatingButton.shadowPath()
        viewStyleTest.layer.shadowPath = viewStyleTest.shadowPath()
    }
    
//    private func updateShadowPaths() {
//        // 각 뷰의 cornerRadius를 고려한 그림자 path 설정
//        [boxTestView, tabBarTestView, floatingButton, viewStyleTest].forEach { view in
//            let path = UIBezierPath(roundedRect: view.bounds,
//                                  cornerRadius: view.layer.cornerRadius)
//            view.layer.shadowPath = path.cgPath
//        }
//    }

    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.CustomColors.Background.background
        
        [boxTestView, tabBarTestView, floatingButton,
         testTextField, testButton, viewStyleTest].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        boxTestView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
        
        tabBarTestView.snp.makeConstraints {
            $0.top.equalTo(boxTestView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
        
        floatingButton.snp.makeConstraints {
            $0.top.equalTo(tabBarTestView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(56)
        }
        
        testTextField.snp.makeConstraints {
            $0.top.equalTo(floatingButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
        
        testButton.snp.makeConstraints {
            $0.top.equalTo(testTextField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(56)
        }
        
        viewStyleTest.snp.makeConstraints {
            $0.top.equalTo(testButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
    }
    
    // traitCollectionDidChange 수정
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 스타일 다시 적용
        boxTestView.applyBoxStyle()
        tabBarTestView.applyTabBarStyle()
        floatingButton.applyFloatingButtonStyle()
        testTextField.applyTextFieldStyle()
        testButton.applyButtonStyle()
        viewStyleTest.applyViewStyle()
        
        // 그림자 경로 업데이트
        updateShadowPaths()

    }
}
