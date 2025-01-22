//
//  ModalTextField.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then

/// 모달에서 텍스트 입력을 받을 텍스트 필드 공용 컴포넌츠
final class ModalTextField: UIView {
    
    // MARK: - UI Components
    
    private let title = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let subTitle = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Personal.normal
        $0.textAlignment = .right
        $0.backgroundColor = .clear
    }
    
    private let textField = UITextField().then {
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
    }
    
    // MARK: - Initializer
    
    /// 텍스트필드 기본 생성자
    /// - Parameters:
    ///   - title: 텍스트필드 대제목
    ///   - subTitle: 텍스트필드 부제목(없을 수 있음)
    ///   - placeholder: placeholder 텍스트
    ///   - keyboardType: 키보드 타입 지정
    init(title: String, subTitle: String?, placeholder: String, keyboardType: UIKeyboardType) {
        super.init(frame: .zero)
        
        self.title.text = title
        self.subTitle.text = subTitle
        self.textField.setPlaceholder(title: placeholder, color: .Light.r400)
        setupUI()
        self.textField.keyboardType = keyboardType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.textField.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        }
    }
    
    /// 텍스트필드를 세팅하는 메소드
    /// - Parameter text: 텍스트필드에 넣을 텍스트
    func configureTextField(text: String?) {
        textField.text = text
    }
    
}

// MARK: - UI Setting Method

private extension ModalTextField {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, subTitle, textField].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        subTitle.snp.makeConstraints {
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
