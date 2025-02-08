//
//  SwitchView.swift
//  TripLog
//
//  Created by 김석준 on 2/8/25.
//

import UIKit
import SnapKit

/// 🔹 `todayView`와 `calendarView`를 전환하는 뷰 (버튼 없음)
final class TripSwitcherView: UIView {

    private let todayView: UIView
    private let calendarView: UIView

    init(todayView: UIView, calendarView: UIView) {
        self.todayView = todayView
        self.calendarView = calendarView
        super.init(frame: .zero)
        setupLayout()
        showTodayView() // 초기값: todayView 보이게 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [todayView, calendarView].forEach {
            addSubview($0)
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }

    /// ✅ `todayView` 표시, `calendarView` 숨김
    func showTodayView() {
        todayView.isHidden = false
        calendarView.isHidden = true
    }

    /// ✅ `calendarView` 표시, `todayView` 숨김
    func showCalendarView() {
        todayView.isHidden = true
        calendarView.isHidden = false
    }
}
