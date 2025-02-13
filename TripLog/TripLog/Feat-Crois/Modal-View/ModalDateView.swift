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
    
    private let startDateIsEmpty = BehaviorSubject<Bool>(value: true)
    private let endDateIsEmpty = BehaviorSubject<Bool>(value: true)
    
    /// 날짜가 모두 선택되었는지 검사하고 이벤트를 방출하는 옵저버블
    fileprivate lazy var dateIsEmpty: Observable<Bool> = {
        return Observable
            .combineLatest(startDateIsEmpty, endDateIsEmpty)
            .map { $0 || $1 }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
    }()
    
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
    
    private let startDatePicker = ModalDatePicker(direction: .left, title: "시작일")
    private let endDatePicker = ModalDatePicker(direction: .right, title: "종료일")
    
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
    
    /// ModalDateView를 설정하는 메소드
    /// - Parameters:
    ///   - start: 여행 시작 일정
    ///   - end: 여행 종료 일정
    func configureDate(start: String, end: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        guard
            let startDate = formatter.date(from: start),
            let endDate = formatter.date(from: end)
        else { return }
        
        self.startDate = startDate
        self.endDate = endDate
        self.startDatePicker.configureDatePicker(date: startDate)
        self.endDatePicker.configureDatePicker(date: endDate)
    }
    
    /// DatePicker뷰의 데이터를 추출하는 메소드
    /// - Returns: DatePicker뷰가 가진 날짜 데이터 튜플타입
    func datePickerExtraction() -> (start: String, end: String) {
        guard let start = startDate, let end = endDate else { return ("","") }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return (formatter.string(from: start), formatter.string(from: end))
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
    
    /// 데이터 바인딩 메소드
    func bind() {
        startDatePickerBind()
        endDatePickerBind()
    }
    
    /// StartDatePicker 바인딩 메소드
    func startDatePickerBind() {
        startDatePicker.rx.selectedDate
            .skip(1)
            .asSignal(onErrorSignalWith: .empty())
            .distinctUntilChanged()
            .withUnretained(self)
            .emit { owner, date in
                
                owner.startDate = date
                owner.startDatePicker.configureDatePicker(date: date)
                
                guard let endDate = owner.endDate,
                      endDate < date
                else { return }
                
                owner.endDate = date
                owner.endDatePicker.configureDatePicker(date: date)
                
            }.disposed(by: disposeBag)
        
        startDatePicker.rx.datePickerIsEmpty
            .bind(to: startDateIsEmpty)
            .disposed(by: disposeBag)
    }
    
    /// EndDatePicker 바인딩 메소드
    func endDatePickerBind() {
        endDatePicker.rx.selectedDate
            .skip(2)
            .asSignal(onErrorSignalWith: .empty())
            .distinctUntilChanged()
            .withUnretained(self)
            .emit { owner, date in
                
                owner.endDate = date
                owner.endDatePicker.configureDatePicker(date: date)
                
                guard let startDate = owner.startDate,
                      startDate > date
                else { return }
                
                owner.startDate = date
                owner.startDatePicker.configureDatePicker(date: date)
                
            }.disposed(by: disposeBag)
        
        endDatePicker.rx.datePickerIsEmpty
            .bind(to: endDateIsEmpty)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: ModalDateView {
    /// 날짜가 선택되었는지 검사하고 이벤트를 방출하는 옵저버블
    var dateIsEmpty: Observable<Bool> {
        return base.dateIsEmpty
    }
}
