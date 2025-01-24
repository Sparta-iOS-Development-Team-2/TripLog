//
//  ModalDateView.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달뷰에서 날짜 설정을 구현한 공용 컴포넌츠
final class ModalDateView: UIView {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
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
        $0.spacing = -0.5
        $0.backgroundColor = .clear
    }
    
    // MARK: - Properties
    
    private var startDate: Date? // 여행 시작 일정을 저장
    private var endDate: Date? // 여행 종료 일정을 저장
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setting Method

private extension ModalDateView {
    
    func setupUI() {
        configureSelf()
        setupStackView()
        setupLayout()
        bind()
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
    
    /// DatePicker 바인딩 메소드
    func bind() {
        startDatePicker.rx.selectedDate
            .skip(1)
            .asSignal(onErrorSignalWith: .empty())
            .distinctUntilChanged()
            .withUnretained(self)
            .emit { owner, date in
                
                owner.startDate = date
                owner.startDatePicker.configureTextField(date: date)
                
                guard let endDate = owner.endDate,
                      endDate < date
                else { return }
                
                owner.endDate = date
                owner.endDatePicker.configureTextField(date: date)
                
            }.disposed(by: disposeBag)
        
        endDatePicker.rx.selectedDate
            .skip(2)
            .asSignal(onErrorSignalWith: .empty())
            .distinctUntilChanged()
            .withUnretained(self)
            .emit { owner, date in
                
                owner.endDate = date
                owner.endDatePicker.configureTextField(date: date)
                
                guard let startDate = owner.startDate,
                      startDate > date
                else { return }
                
                owner.startDate = date
                owner.startDatePicker.configureTextField(date: date)
                
            }.disposed(by: disposeBag)
    }
    
}
