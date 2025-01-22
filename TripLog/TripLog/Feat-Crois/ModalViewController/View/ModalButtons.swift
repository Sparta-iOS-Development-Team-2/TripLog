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

final class ModalButtons: UIView {
    
    fileprivate let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.Dark.base, for: .normal)
        $0.titleLabel?.font = .SCDream(size: .headline, weight: .medium)
        $0.titleLabel?.numberOfLines = 1
        $0.titleLabel?.textAlignment = .center
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        $0.layer.borderWidth = 1
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
    
    init(buttonTitle: String) {
        super.init(frame: .zero)
        
        self.createButton.setTitle(buttonTitle, for: .normal)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.cancelButton.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        }
    }
    
}

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

extension Reactive where Base: ModalButtons {
    var activeButtondTapped: Observable<Void> {
        return base.createButton.rx.tap.asObservable()
    }
    
    var cancelButtondTapped: Observable<Void> {
        return base.cancelButton.rx.tap.asObservable()
    }
}
