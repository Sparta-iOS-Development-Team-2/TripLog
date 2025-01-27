//
//  ModalButtons.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달에서 버튼을 구현한 공용 컴포넌츠
final class ModalButtons: UIView {
    
    // MARK: - UI Components
    
    fileprivate let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.Dark.base, for: .normal)
        $0.titleLabel?.font = .SCDream(size: .headline, weight: .medium)
        $0.titleLabel?.numberOfLines = 1
        $0.titleLabel?.textAlignment = .center
        $0.applyButtonStyle()
    }
    
    fileprivate let createButton = UIButton().then {
        $0.titleLabel?.font = .SCDream(size: .headline, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.numberOfLines = 1
        $0.titleLabel?.textAlignment = .center
        $0.backgroundColor = .Personal.normal
        $0.layer.cornerRadius = 8
    }
    
    private lazy var buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 16
    }
    
    // MARK: - Initializer
    
    init(buttonTitle: String) {
        super.init(frame: .zero)
        
        self.createButton.setTitle(buttonTitle, for: .normal)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.cancelButton.applyButtonStroke()
        }
    }
    
}

// MARK: - UI Setting Method

private extension ModalButtons {
    
    func setupUI() {
        configureSelf()
        setupStackView()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.addSubview(buttonStack)
    }
    
    func setupStackView() {
        [cancelButton, createButton].forEach { self.buttonStack.addArrangedSubview($0) }
    }
    
    func setupLayout() {
        buttonStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: ModalButtons {
    /// active 버튼을 클릭했을 때 이벤트를 방출하는 옵저버블
    var activeButtondTapped: Observable<Void> {
        return base.createButton.rx.tap.asObservable()
    }
    
    /// cancel 버튼을 클릭했을 때 이벤트를 방출하는 옵저버블
    var cancelButtondTapped: Observable<Void> {
        return base.cancelButton.rx.tap.asObservable()
    }
}
