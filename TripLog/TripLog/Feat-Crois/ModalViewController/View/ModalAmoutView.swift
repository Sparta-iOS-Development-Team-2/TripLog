//
//  ModalAmoutView.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class ModalAmoutView: UIView {
    
    private let title = UILabel().then {
        $0.text = "금액"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let currencyButton = UIButton().then {
        $0.setTitle("원(한화)", for: .normal)
        $0.setTitleColor(UIColor.Personal.normal, for: .normal)
        $0.titleLabel?.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.tintColor = UIColor.Personal.normal
        $0.backgroundColor = .clear
    }
    
    private let textField = UITextField().then {
        $0.setPlaceholder(title: "0", color: .Light.r400)
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = UIColor.Dark.base
        $0.borderStyle = .none
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        $0.layer.borderWidth = 1
        $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.rightViewMode = .always
        $0.autocapitalizationType = .none
        $0.keyboardType = .numberPad
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ModalAmoutView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        configureMenuForButton()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, currencyButton, textField].forEach { self.addSubview($0) }
    }
    
    func configureMenuForButton() {
        // 메뉴 항목 생성
        let children: [UIAction] = {
            var childrens: [UIAction] = []
            
            Currency.allCurrencies.forEach { currency in
                let action = UIAction(title: currency, handler: { [weak self] _ in
                    self?.currencyButton.setTitle(currency, for: .normal)
                })
                childrens.append(action)
            }
            return childrens
        }()
        
        // UIMenu 생성
        let menu = UIMenu(title: "환율 선택", options: .displayInline, children: children)
        
        // UIButton에 메뉴 연결
        currencyButton.menu = menu
        currencyButton.showsMenuAsPrimaryAction = true // 버튼 클릭 시 메뉴 표시
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        currencyButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(title)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
}