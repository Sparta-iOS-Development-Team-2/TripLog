//
//  ModalDataPicker.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class ModalDatePicker: UIView {
        
    fileprivate let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
        $0.locale = .init(identifier: "KO_kr")
    }
    
    private let textField = UITextField().then {
        $0.setPlaceholder(title: "mm/dd/yyyy", color: .Light.r400)
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = UIColor.Dark.base
        $0.borderStyle = .none
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor.Light.base
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        $0.layer.borderWidth = 1
        $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.rightViewMode = .always
        $0.autocapitalizationType = .none
        $0.keyboardType = .default
        $0.isEnabled = false
    }
    
    private let calendarView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = .Dark.base
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    init(direction: ModalDatePickerDirection) {
        super.init(frame: .zero)
        
        setupUI()
        switch direction {
        case .right:
            textField.layer.maskedCorners = [.layerMaxXMinYCorner
                                      , .layerMaxXMaxYCorner]
            
        case .left:
            textField.layer.maskedCorners = [.layerMinXMinYCorner
                                      , .layerMinXMaxYCorner]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.textField.layer.borderColor = UIColor.Dark.base.withAlphaComponent(0.1).cgColor
        }
    }
    
    func configTextField(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        self.textField.text = formatter.string(from: date)
    }
    
}

private extension ModalDatePicker {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [datePicker, textField, calendarView].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        datePicker.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
}

extension Reactive where Base: ModalDatePicker {
    var selectedDate: Observable<Date> {
        return base.datePicker.rx.date.asObservable()
    }
}
