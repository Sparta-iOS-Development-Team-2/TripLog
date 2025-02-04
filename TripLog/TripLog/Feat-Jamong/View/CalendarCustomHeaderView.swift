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
    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Text.textPrimary
    }
    
    /// 다음 달로 이동하는 버튼
    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Text.textPrimary
    }
    
    // MARK: - Properties
    /// 연결된 FSCalendar 인스턴스
    /// - weak 참조를 통해 순환 참조 방지
    weak var calendar: FSCalendar?
    
    /// RxSwift 리소스 정리를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    /// UI 컴포넌트들의 초기 설정을 담당하는 메서드
    private func setupUI() {
        // 서브뷰 추가
        [previousButton, titleLabel, nextButton].forEach { addSubview($0) }
        
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - Constraints Setup
    /// UI 컴포넌트들의 제약조건을 설정하는 메서드
    private func setupConstraints() {
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
    
    /// 현재 표시된 달의 제목을 업데이트하는 메서드
    /// - Parameter date: 표시할 날짜
    /// - "yyyy년 M월" 형식으로 타이틀 업데이트
    func updateTitle(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        titleLabel.text = formatter.string(from: date)
    }
    
    /// 버튼 이벤트 바인딩을 설정하는 메서드
    /// - RxSwift를 사용하여 버튼 탭 이벤트 처리
    /// - 이전/다음 달로 페이지 전환 및 타이틀 업데이트
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
