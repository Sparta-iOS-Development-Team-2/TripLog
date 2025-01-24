//
//  CalendarViewController.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//

import UIKit
import RxSwift
import Then
import SnapKit
import FSCalendar

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var calendarView = CalendarView()
    private let disposeBag = DisposeBag()
    
    // 지출 금액 표시 레이블
    private lazy var expenseLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
        $0.text = "총 지출: ₩0" // Default text
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendarDelegate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 서브뷰 추가
        [calendarView, expenseLabel].forEach { view.addSubview($0) }
        
        // SnapKit을 사용한 레이아웃 설정
        calendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        expenseLabel.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
    }
    
    private func setupCalendarDelegate() {
        calendarView.delegate = self
    }
}

// MARK: - FSCalendarDelegate Extension
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let randomExpense = Int.random(in: 1000...100000)
        expenseLabel.text = "선택한 날짜 지출: ₩\(randomExpense)"
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
}
