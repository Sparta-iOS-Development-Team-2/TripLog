//
//  TripLogSummaryView.swift
//  TripLog
//
//  Created by 김석준 on 2/12/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 🔹 여행 요약 정보를 표시하는 뷰 (타이틀, 날짜, 예산, 진행 상태, 버튼 포함)
final class TripLogSummaryView: UIView {
    
    private var disposeBag = DisposeBag()
    
    private let switcherView: TripSwitcherView
    
    /// 🔹 `titleDateView`, `progressView`, `buttonStackView`를 감싸는 컨테이너 뷰
    private let tripSummaryContainerView = UIView().then {
        $0.backgroundColor = UIColor.CustomColors.Background.background
    }
    
    private let titleDateView = TitleDateView()
    let progressView = TopProgressView()
    private let buttonStackView = TopCustomButtonStackView()
    
    /// ✅ `TripSwitcherView`를 인자로 받아 초기화
    init(switcherView: TripSwitcherView) {
        self.switcherView = switcherView
        super.init(frame: .zero)
        setupLayout()
        setupButtonActions()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    /// ✅ 여행 정보를 설정하는 메서드
    func configure(subtitle: String, date: String, budget: Int, amount: Int) {
        titleDateView.configure(subtitle: subtitle, date: date)
        progressView.setBudget(budget)
        progressView.expense.accept(amount)
    }
    
    private func setupLayout() {
        /// ✅ tripSummaryContainerView 내부에 `titleDateView`, `progressView`, `buttonStackView` 추가
        [titleDateView, progressView, buttonStackView].forEach { tripSummaryContainerView.addSubview($0) }
        
        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(64)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(-1)
            $0.bottom.equalToSuperview()
        }

        addSubview(tripSummaryContainerView)
        addSubview(switcherView)
        
        /// ✅ `tripSummaryContainerView` 레이아웃 설정
        tripSummaryContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(190)
        }
        
        switcherView.snp.makeConstraints {
            $0.top.equalTo(tripSummaryContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    
    }
    
    /// ✅ 버튼 클릭 시 `TripSwitcherView`의 뷰 변경
    private func setupButtonActions() {
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.switcherView.showTodayView()
            },
            calendarAction: { [weak self] in
                self?.switcherView.showCalendarView()
            }
        )
    }
}
