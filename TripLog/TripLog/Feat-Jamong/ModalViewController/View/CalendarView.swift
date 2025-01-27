//
//  CalendarView.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//


import UIKit
import FSCalendar
import Then
import SnapKit


final class CalendarView: UIView, FSCalendarDelegate, FSCalendarDataSource {
    // MARK: - Properties
    lazy var calendar = FSCalendar().then {
        // Delegate, DataSource 설정
        $0.delegate = self
        $0.dataSource = self

        // MARK: - CalendarView Set UI
        $0.appearance.do {
            // 다크모드 UI+Extension Color 설정 필요함.
            $0.weekdayFont = .SCDream(size: .display, weight: .medium)
            $0.titleFont = .SCDream(size: .body, weight: .medium)
            $0.weekdayTextColor = .black
            $0.titleDefaultColor = .black
            $0.selectionColor = .systemBlue
            $0.todayColor = .gray
            $0.todaySelectionColor = .systemBlue
            $0.caseOptions = .weekdayUsesSingleUpperCase
        }
        
        // 기본 헤더 제거
        $0.headerHeight = 0
        $0.appearance.headerMinimumDissolvedAlpha = 0
        
        // 한국어 및 이전, 이후 달 일자 보이기
        $0.locale = Locale(identifier: "ko_KR")
        $0.placeholderType = .fillHeadTail
    }

    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // UI+Extension Color로 설정 필요함.
        backgroundColor = .white
        addSubview(calendar)

        calendar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
