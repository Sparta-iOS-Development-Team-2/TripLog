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
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white    // UI+Extension Color로 설정 필요함.
        addSubview(calendar)
        
        calendar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
