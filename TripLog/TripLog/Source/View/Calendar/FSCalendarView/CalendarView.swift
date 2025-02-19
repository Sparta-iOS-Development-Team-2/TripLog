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

/// FSCalendar를 래핑한 커스텀 캘린더 뷰
/// - 캘린더의 기본적인 UI와 동작 설정
/// - 날짜 선택, 다크모드 대응
/// - 정사각형 셀 레이아웃
final class CalendarView: UIView {
    // MARK: - Properties
    /// FSCalendar
    lazy var calendar = FSCalendar().then {
        // 기본 설정
        $0.allowsMultipleSelection = false
        $0.locale = Locale(identifier: "ko_KR")
        $0.formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        $0.placeholderType = .fillHeadTail
        $0.scrollEnabled = false
        
        // 헤더 설정
        $0.headerHeight = 0
        $0.appearance.headerMinimumDissolvedAlpha = 0
        
        // 레이아웃 설정
        let cellWidth = CGFloat(361 - 20) / 7
        $0.rowHeight = cellWidth
        $0.weekdayHeight = 30
        
        // 외관 설정
        setupCalendarAppearance($0)
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
        addSubview(calendar)
        
        calendar.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    /// 캘린더의 외관을 설정하는 메서드
    /// - Parameter calendar: 설정할 FSCalendar 인스턴스
    private func setupCalendarAppearance(_ calendar: FSCalendar) {
        calendar.appearance.do {
            // 폰트 설정
            $0.weekdayFont = .SCDream(size: .display, weight: .medium)
            $0.titleFont = .SCDream(size: .body, weight: .medium)
            
            // 색상 설정
            $0.weekdayTextColor = UIColor.CustomColors.Text.textPrimary
            $0.titleDefaultColor = UIColor.CustomColors.Text.textPrimary
            $0.titleTodayColor = UIColor.CustomColors.Text.textPrimary
            
            // 선택 및 오늘 표시 설정
            $0.selectionColor = .clear
            $0.todayColor = .clear
            $0.todaySelectionColor = .clear
            
            // 요일 표시 설정
            $0.caseOptions = .weekdayUsesSingleUpperCase
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCellSize()
    }
    
    /// 셀 크기를 업데이트하는 메서드
    private func updateCellSize() {
        let cellWidth = bounds.width / 7
        calendar.rowHeight = cellWidth
    }
    
    // MARK: - Trait Collection
    /// 다크모드 변경 등 trait collection이 변경될 때 호출되는 메서드
    /// - Parameter previousTraitCollection: 이전 trait collection 정보
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
    
    /// 다크모드에 따른 컬러 업데이트 메서드
    private func updateColors() {
        calendar.appearance.do {
            $0.weekdayTextColor = UIColor.CustomColors.Text.textPrimary
            $0.titleDefaultColor = UIColor.CustomColors.Text.textPrimary
            $0.titleTodayColor = UIColor.CustomColors.Text.textPrimary
        }
        calendar.reloadData()
    }
    
    func updatePageLoad(date: Date) {
        calendar.scrollEnabled = true
        calendar.setCurrentPage(date, animated: true)
        calendar.scrollEnabled = false
    }
}

// MARK: - Extension for Setup Methods
extension CalendarView {
    /// 캘린더의 커스텀 설정을 적용하는 메서드
    /// - 셀 등록 및 이벤트 색상 설정
    func setupCustomCalendar() {
        calendar.register(CalendarCustomCell.self, forCellReuseIdentifier: "CalendarCustomCell")
        
        calendar.appearance.do {
            $0.eventDefaultColor = UIColor.CustomColors.Accent.blue
            $0.eventSelectionColor = UIColor.CustomColors.Accent.blue
        }
    }
}
