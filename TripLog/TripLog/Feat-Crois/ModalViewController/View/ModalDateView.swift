//
//  ModalDateView.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import UIKit
import SnapKit
import Then

final class ModalDateView: UIView {
    
    private let title = UILabel().then {
        $0.text = "여행 일정"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let startDatePicker = ModalDatePicker(direction: .left)
    private let endDatePicker = ModalDatePicker(direction: .right)
    
    private let datePickerStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ModalDateView {
    
    func setupUI() {
        configureSelf()
        setupStackView()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, datePickerStack].forEach { self.addSubview($0) }
    }
    
    func setupStackView() {
        [startDatePicker, endDatePicker].forEach {
            self.datePickerStack.addArrangedSubview($0)
        }
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        datePickerStack.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
}