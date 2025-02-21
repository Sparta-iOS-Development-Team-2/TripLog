//
//  CalendarCustomCell.swift
//  TripLog
//
//  Created by Jamong on 1/28/25.
//

import UIKit
import FSCalendar
import Then
import SnapKit

/// FSCalendar의 커스텀 셀
/// - 날짜와 해당 날짜의 지출 금액을 표시하는 셀
/// - 선택 상태에 따른 UI 변경 처리
final class CalendarCustomCell: FSCalendarCell {
    // MARK: - UI Components
    /// 일자 라벨
    public let dateLabel = UILabel().then {
        $0.font = .SCDream(size: .caption, weight: .medium)
        $0.textAlignment = .center
    }
    
    /// 해당 일자 지출 금액 라벨
    public let expenseLabel = UILabel().then {
        $0.font = .SCDream(size: .subcaption, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .red
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.75
        $0.numberOfLines = 1
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // MARK: - UI Setup
    /// UI 컴포넌트들의 초기 설정을 담당하는 메서드
    private func setupUI() {
        setupSubviews()
        setupConstraints()
    }
    
    /// 서브뷰들을 contentView에 추가하는 메서드
    private func setupSubviews() {
        [dateLabel, expenseLabel].forEach { contentView.addSubview($0) }
    }
    
    /// UI 컴포넌트들의 제약조건을 설정하는 메서드
    private func setupConstraints() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }
        
        expenseLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Override Methods
    /// 셀이 재사용될 때 호출되는 메서드
    /// - 모든 상태를 초기화하여 재사용 시 이전 상태가 남지 않도록 함
    override func prepareForReuse() {
        super.prepareForReuse()
        resetState()
    }
    
    // MARK: - Private Methods
    /// 셀의 모든 상태를 초기화하는 메서드
    /// - 텍스트, 텍스트 컬러, 배경색, 코너 반경 등을 기본값으로 재설정
    private func resetState() {
        dateLabel.text = nil
        expenseLabel.text = nil
        expenseLabel.textColor = .red
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 0
    }

}
