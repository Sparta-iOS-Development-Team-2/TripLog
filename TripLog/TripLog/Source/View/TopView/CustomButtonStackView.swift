//
//  CustomButtonStackView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CustomButtonStackView: UIStackView {
    
    fileprivate let expenditureButton = UIButton(type: .system)
    fileprivate let calendarButton = UIButton(type: .system)
    
    // 선택된 상태 추적
    private var firstButtonSelected: Bool = true {
        didSet {
            updateButtonStyles()
        }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
        setupLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        expenditureButton.applyTextFieldStroke()
        calendarButton.applyTextFieldStroke()
    }
    
    /// 버튼을 선택했을 때, 스타일을 변경하는 메소드
    func changeButtonStyle(_ firstButtonSelected: Bool) {
        self.firstButtonSelected = firstButtonSelected
    }
}

private extension CustomButtonStackView {
    
    func setupButtons() {
        configureButton(expenditureButton, title: "지출 내역")
        configureButton(calendarButton, title: "캘린더")
        
        // 스택 뷰에 버튼 추가
        addArrangedSubview(expenditureButton)
        addArrangedSubview(calendarButton)
        applyBackgroundColor()
        
        // 초기 스타일 설정
        updateButtonStyles()
    }
    
    func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.SCDream(size: .display, weight: .bold)
        button.applyTextFieldStroke()
    }
    
    func setupLayout() {
        axis = .horizontal
        spacing = -0.5
        distribution = .fillEqually
    }
    
    // 버튼 스타일 업데이트
    func updateButtonStyles() {
        let todayFontWeight: UIFont.Weight = firstButtonSelected ? .bold : .medium
        let calendarFontWeight: UIFont.Weight = firstButtonSelected ? .medium : .bold
        
        expenditureButton.setTitleColor(firstButtonSelected ? .CustomColors.Accent.blue : UIColor.CustomColors.Text.textSecondary, for: .normal)
        calendarButton.setTitleColor(firstButtonSelected ? UIColor.CustomColors.Text.textSecondary : .CustomColors.Accent.blue, for: .normal)
        
        expenditureButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: todayFontWeight)
        calendarButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: calendarFontWeight)
    }
}

extension Reactive where Base: CustomButtonStackView {
    
    var firstButtonTapped: ControlEvent<Void> {
        base.expenditureButton.rx.tap
    }
    
    var secondButtonTapped: ControlEvent<Void> {
        base.calendarButton.rx.tap
    }
    
}
