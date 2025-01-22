//
//  ButtonStackView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//

import UIKit

class CustomButtonStackView: UIStackView {

    let todayExpenseButton = UIButton(type: .system)
    let calendarButton = UIButton(type: .system)

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
        
        let grayColor = UIColor(red: 0x73 / 255.0, green: 0x73 / 255.0, blue: 0x73 / 255.0, alpha: 1.0)
        
        // "오늘 지출" 버튼 설정
        todayExpenseButton.setTitle("오늘 지출", for: .normal)
        todayExpenseButton.setTitleColor(UIColor(named: "normal"), for: .normal)
        todayExpenseButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: .bold)
        todayExpenseButton.layer.borderColor = UIColor.lightGray.cgColor
        todayExpenseButton.layer.borderWidth = 1

        // "캘린더" 버튼 설정
        calendarButton.setTitle("캘린더", for: .normal)
        calendarButton.setTitleColor(grayColor, for: .normal)
        calendarButton.titleLabel?.font = UIFont.SCDream(size: .display, weight: .bold)
        calendarButton.layer.borderColor = UIColor.lightGray.cgColor
        calendarButton.layer.borderWidth = 1

        // 스택 뷰에 버튼 추가
        addArrangedSubview(todayExpenseButton)
        addArrangedSubview(calendarButton)
    }

    private func setupLayout() {
        // 스택 뷰 레이아웃 설정
        axis = .horizontal
        spacing = 0
        distribution = .fillEqually
    }
}
