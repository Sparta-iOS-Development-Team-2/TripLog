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
    // 캘린더 뷰
    private lazy var calendarView = CalendarView().then {
        $0.calendar.delegate = self
        $0.calendar.dataSource = self
    }
    // 커스텀 헤더 뷰
    private lazy var customHeaderView = CalendarCustomHeaderView(frame: .zero).then {
        $0.calendar = calendarView.calendar
    }
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
    }
    
    // 하위 뷰 레이아웃 업데이트 된 후 호출
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.calendar.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 서브뷰 추가
        [customHeaderView, calendarView].forEach { view.addSubview($0) }
        
        customHeaderView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(customHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // 캘린더 헤더 타이틀 설정
    private func setupCalendar() {
        customHeaderView.updateTitle(date: calendarView.calendar.currentPage)
    }
    
    // MARK: - Public Methods
    /// 캘린더의 현재 페이지를 지정된 날짜로 변경
    /// - Parameter date: 이동할 날짜
    func changeMonth(to date: Date) {
        calendarView.calendar.setCurrentPage(date, animated: true)
    }
}

// MARK: - FSCalendarDelegate Extension
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    /// 캘린더의 현재 페이지가 변경되었을 때 호출
    /// - Parameter calendar: 변경된 캘린더 객체
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        customHeaderView.updateTitle(date: calendar.currentPage)
    }
}
