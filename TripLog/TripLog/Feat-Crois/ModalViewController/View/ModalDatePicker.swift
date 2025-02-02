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

/// 모달뷰에서 날짜를 선택하는 공용 컴포넌츠
final class ModalDatePicker: UIView {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    fileprivate let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
        $0.locale = .init(identifier: "KO_kr")
    }
    
    fileprivate let textField = UITextField().then {
        $0.setPlaceholder(title: "mm/dd/yyyy", color: .Light.r400)
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = UIColor.Dark.base
        $0.borderStyle = .none
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
        $0.applyTextFieldStyle()
        $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.rightViewMode = .always
        $0.autocapitalizationType = .none
        $0.keyboardType = .default
        $0.isUserInteractionEnabled = false
    }
    
    private let calendarView = UIImageView().then {
        $0.image = UIImage(systemName: "calendar")
        $0.tintColor = .Dark.base
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializer
    
    /// DatePicker뷰의 기본 생성자
    /// - Parameter direction: 데이트 픽커의 방향(방향에 따라 cornerRadius 값이 바뀜)
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
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.textField.applyTextFieldStroke()
        }
    }
    
    func configureDatePicker(date: Date) {
        datePicker.rx.date.onNext(date)
        updateTextField(date: date)
    }
}

// MARK: - UI Setting Method

private extension ModalDatePicker {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bind()
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
    
    /// DatePicker 뷰의 날짜를 설정하는 메소드
    /// - Parameter date: 입력할 날짜
    func updateTextField(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        DispatchQueue.main.async { [weak self] in
            self?.textField.text = formatter.string(from: date)
            self?.textField.sendActions(for: .valueChanged)
        }
    }
    
    func bind() {
        datePicker.rx.date
            .skip(1)
            .distinctUntilChanged()
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, date in
                
                owner.updateTextField(date: date)
                
            }.disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: ModalDatePicker {
    /// DatePicker의 날짜가 선택되면 해당 날짜를 이벤트로 방출하는 옵저버블
    var selectedDate: Observable<Date> {
        return base.datePicker.rx.date.asObservable()
    }
    
    /// DatePicker의 날짜가 선택되었는지 확인하는 옵저버블
    var datePickerIsBlank: Observable<Bool> {
        return base.textField.rx.text.orEmpty
            .map { $0.count <= 0 }
            .distinctUntilChanged()
            .asObservable()
    }
}
