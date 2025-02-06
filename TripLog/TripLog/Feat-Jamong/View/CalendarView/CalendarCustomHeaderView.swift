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

/// FSCalendar의 커스텀 헤더 뷰
/// - 현재 표시된 년월을 보여주는 타이틀
/// - 이전/다음 달로 이동할 수 있는 네비게이션 버튼
/// - RxSwift를 사용한 버튼 이벤트 처리
class CalendarCustomHeaderView: UIView {
    // MARK: - UI Components
    /// 현재 표시된 년월을 나타내는 레이블
    private let titleLabel = UILabel().then {
        $0.font = .SCDream(size: .display, weight: .bold)
        $0.textColor = UIColor.CustomColors.Text.textPrimary
        $0.textAlignment = .center
    }
    
    /// 이전 달로 이동하는 버튼
    fileprivate let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Text.textPrimary
    }
    
    /// 다음 달로 이동하는 버튼
    fileprivate let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Text.textPrimary
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
    /// UI 컴포넌트들의 제약조건을 설정하는 메서드
    private func setupUI() {
        // 서브뷰 추가
        [previousButton, titleLabel, nextButton].forEach { addSubview($0) }
        
        // 뷰 자체 높이 설정
        snp.makeConstraints {
            $0.height.equalTo(80)
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
    
    func updateTitle(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        titleLabel.text = formatter.string(from: date)
    }
}

extension Reactive where Base: CalendarCustomHeaderView {
    var previousButtonTapped : Observable<Void> {
        base.previousButton.rx.tap.asObservable()
    }
    
    var nextButtonTapped: Observable<Void> {
        base.nextButton.rx.tap.asObservable()
    }
}

