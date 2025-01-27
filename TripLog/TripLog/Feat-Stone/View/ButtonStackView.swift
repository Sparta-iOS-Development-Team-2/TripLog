//
//  ButtonStackView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//

import UIKit

class CustomButtonStackView: UIStackView {

    private let todayExpenseButton = UIButton(type: .system)
    private let calendarButton = UIButton(type: .system)

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

    private func setupButtons() {
        // 버튼 공통 설정
        configureButton(todayExpenseButton, title: "오늘 지출", titleColor: UIColor(named: "normal"))
        configureButton(calendarButton, title: "캘린더", titleColor: UIColor(red: 0x73 / 255.0, green: 0x73 / 255.0, blue: 0x73 / 255.0, alpha: 1.0))

        // 스택 뷰에 버튼 추가
        addArrangedSubview(todayExpenseButton)
        addArrangedSubview(calendarButton)
    }

    private func configureButton(_ button: UIButton, title: String, titleColor: UIColor?) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.SCDream(size: .display, weight: .bold)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
    }

    private func setupLayout() {
        // 스택 뷰 레이아웃 설정
        axis = .horizontal
        spacing = 0
        distribution = .fillEqually
    }
}
