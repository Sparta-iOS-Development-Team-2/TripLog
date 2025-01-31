//
//  CalendarCustomHeaderView.swift
//  TripLog
//
//  Created by Jamong on 1/26/25.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import Then
import SnapKit

class CalendarCustomHeaderView: UIView {
    // MARK: - UI Components
    let titleLabel = UILabel()
    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    
    // MARK: - Properties
    weak var calendar: FSCalendar?
    private let disposeBag = DisposeBag()
    
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
        }
        
        // 다음 달 버튼 설정
        nextButton.do {
            $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            $0.tintColor = .black
        }
        
        // 날짜 라벨 설정
        titleLabel.do {
            $0.font = .SCDream(size: .display, weight: .bold)
            $0.textColor = .black
            $0.textAlignment = .center
        }
        
        setupConstraints()
        setupBindings()
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
    
    // 버튼 조작 바인딩
    private func setupBindings() {
       previousButton.rx.tap
           .subscribe(onNext: { [weak self] in
               guard let self = self,
                     let currentPage = self.calendar?.currentPage else { return }
               let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage) ?? currentPage
               self.calendar?.setCurrentPage(previousMonth, animated: true)
               self.updateTitle(date: previousMonth)
           })
           .disposed(by: disposeBag)
       
       nextButton.rx.tap
           .subscribe(onNext: { [weak self] in
               guard let self = self,
                     let currentPage = self.calendar?.currentPage else { return }
               let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage) ?? currentPage
               self.calendar?.setCurrentPage(nextMonth, animated: true)
               self.updateTitle(date: nextMonth)
           })
           .disposed(by: disposeBag)
    }
}


