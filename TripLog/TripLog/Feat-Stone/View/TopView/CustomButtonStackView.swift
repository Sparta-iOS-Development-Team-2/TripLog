//
//  CustomButtonStackView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//

import UIKit

class TopCustomButtonStackView: UIStackView {

    private let todayExpenseButton = UIButton(type: .system)
    private let calendarButton = UIButton(type: .system)
    
    // 선택된 상태 추적
    private var isTodaySelected: Bool = true {
        didSet {
            updateButtonStyles()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
        setupLayout()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
        setupLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        todayExpenseButton.applyTextFieldStroke()
        calendarButton.applyTextFieldStroke()
    }

    private func setupButtons() {
        configureButton(todayExpenseButton, title: "오늘 지출")
        configureButton(calendarButton, title: "캘린더")

        // 스택 뷰에 버튼 추가
        addArrangedSubview(todayExpenseButton)
        addArrangedSubview(calendarButton)
        applyBackgroundColor()
        
        // 초기 스타일 설정
        updateButtonStyles()

        // 버튼 액션 추가
        todayExpenseButton.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
    }

    private func configureButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.SCDream(size: .display, weight: .bold)
        button.applyTextFieldStroke()
    }
    
    private func setupLayout() {
        axis = .horizontal
        spacing = -1
        distribution = .fillEqually
//        alignment = .center
    }

    // 버튼 스타일 업데이트
    private func updateButtonStyles() {
        let todayFontWeight: UIFont.Weight = isTodaySelected ? .bold : .medium
        let calendarFontWeight: UIFont.Weight = isTodaySelected ? .medium : .bold

        todayExpenseButton.setTitleColor(isTodaySelected ? UIColor.Personal.normal : UIColor.CustomColors.Text.textSecondary, for: .normal)
        calendarButton.setTitleColor(isTodaySelected ? UIColor.CustomColors.Text.textSecondary : UIColor.Personal.normal, for: .normal)

        todayExpenseButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: todayFontWeight)
        calendarButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: calendarFontWeight)
    }


    // 오늘 지출 버튼 클릭
    @objc private func todayButtonTapped() {
        isTodaySelected = true
        todayButtonAction?()
    }

    // 캘린더 버튼 클릭
    @objc private func calendarButtonTapped() {
        isTodaySelected = false
        calendarButtonAction?()
    }
    
    // 버튼 액션 설정 메서드 추가
    private var todayButtonAction: (() -> Void)?
    private var calendarButtonAction: (() -> Void)?

    func setButtonActions(todayAction: @escaping () -> Void, calendarAction: @escaping () -> Void) {
        self.todayButtonAction = todayAction
        self.calendarButtonAction = calendarAction
    }
}
