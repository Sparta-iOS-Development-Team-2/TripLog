//
//  ModalButtons.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then

final class ModalButtons: UIView {
    
    private(set) var cancelButton = UIButton().then {
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
    
    private(set) var createButton = UIButton().then {
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
