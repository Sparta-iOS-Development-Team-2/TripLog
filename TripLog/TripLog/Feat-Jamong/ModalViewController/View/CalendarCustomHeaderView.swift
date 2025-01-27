//
//  CalendarCustomHeaderView.swift
//  TripLog
//
//  Created by Jamong on 1/26/25.
//

import UIKit
import FSCalendar
import Then
import SnapKit

class CalendarCustomHeaderView: UIView {
    // MARK: - UI Components
    let titleLabel = UILabel()
    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    
    // MARK: - Properties
    weak var calendar: FSCalendar?
    
    // MARK: - Initalization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 서브뷰 추가
        [previousButton, titleLabel, nextButton].forEach { addSubview($0) }
        
        // 다크모드 UI+Extension Color 설정 필요함.
        
        // 이전 달 버튼 설정
        previousButton.do {
            $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            $0.tintColor = .black
            $0.addTarget(self, action: #selector(handlePreviousMonth), for: .touchUpInside)
        }
        
        // 다음 달 버튼 설정
        nextButton.do {
            $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            $0.tintColor = .black
            $0.addTarget(self, action: #selector(handleNextMonth), for: .touchUpInside)
        }
        
        // 날짜 라벨 설정
        titleLabel.do {
            $0.font = .SCDream(size: .display, weight: .bold)
            $0.textColor = .black
            $0.textAlignment = .center
        }
        
        setupConstraints()
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        // 뷰 자체 높이 설정
        snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        // 이전 달 버튼 제약 조건
        previousButton.snp.makeConstraints {
            $0.left.centerY.equalToSuperview()
            $0.width.equalTo(40)
        }
        
        // 날짜 라벨 제약 조건
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // 다음 달 버튼 제약 조건
        nextButton.snp.makeConstraints {
            $0.right.centerY.equalToSuperview()
            $0.width.equalTo(40)
        }
    }
    
    /// 현재 표시된 달의 제목을 업데이트한다.
    /// - Parameter date: 표시할 날짜
    func updateTitle(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy년 M월"
        titleLabel.text = formatter.string(from: date)
    }
    
    /// 이전 달로 이동하는 버튼 액션을 처리한다.
    @objc func handlePreviousMonth() {
        print("클릭")
        calendar?.setCurrentPage(getPreviousMonth(date: calendar?.currentPage ?? Date()), animated: true)
        updateTitle(date: calendar?.currentPage ?? Date())
    }
    
    /// 다음 달로 이동하는 버튼 액션을 처리한다.
    @objc func handleNextMonth() {
        print("클릭")
        calendar?.setCurrentPage(getNextMonth(date: calendar?.currentPage ?? Date()), animated: true)
        updateTitle(date: calendar?.currentPage ?? Date())
    }
    
    /// 주어진 날짜의 이전 달을 반환한다.
    /// - Parameter date: 기준 날짜
    /// - Returns: 이전 달의 날짜
    private func getPreviousMonth(date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    /// 주어진 날짜의 다음 달을 반환한다.
    /// - Parameter date: 기준 날짜
    /// - Returns: 다음 달의 날짜
    private func getNextMonth(date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
    }
}
