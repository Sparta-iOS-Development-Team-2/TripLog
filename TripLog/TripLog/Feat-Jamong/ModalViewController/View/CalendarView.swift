//
//  CalendarView.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//


import UIKit
import FSCalendar
import SnapKit
import Then

final class CalendarView: UIView {
    // MARK: - Properties
    weak var delegate: FSCalendarDelegate? {
        didSet {
            calendar.delegate = delegate
        }
    }
    
    private lazy var calendar = FSCalendar().then {
        // 스크롤 방향 설정
        $0.scrollDirection = .horizontal
        
        // 캘린더 스코프 설정 -> month: 월간, week: 주간
        $0.scope = .month
        
        $0.appearance.do {
            // 헤더(년월) 포맷 및 스타일 설정
            $0.headerDateFormat = "YYYY년 MM월"
            $0.headerTitleColor = .black
            $0.headerTitleFont = .boldSystemFont(ofSize: 16)
            $0.headerMinimumDissolvedAlpha = 0.0
            
            // 요일 레이블 스타일 설정
            $0.weekdayFont = .systemFont(ofSize: 14)
            $0.weekdayTextColor = .gray
            
            // 날짜 셀 스타일 설정
            $0.titleFont = .systemFont(ofSize: 14)
            $0.titleDefaultColor = .black
            $0.titleSelectionColor = .white
            
            $0.subtitleFont = .systemFont(ofSize: 10)
            $0.subtitleDefaultColor = .systemGray
            
            $0.subtitleOffset = CGPoint(x: 0, y: 2)
            
            $0.selectionColor = .systemBlue
            $0.todayColor = .systemGray4
            
            // 이벤트 표시 스타일 설정
            $0.eventDefaultColor = .systemBlue
            $0.eventSelectionColor = .white
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(calendar)
        
        calendar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
