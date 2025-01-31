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

class CalendarCustomCell: FSCalendarCell {
    // MARK: - UI Components
    
    /// 일자 라벨
    public let dateLabel = UILabel().then {
        $0.font = .SCDream(size: .caption, weight: .medium)
        $0.textAlignment = .center
    }
    
    /// 해당 일자 지출 금액 라벨
    public let expenseLabel = UILabel().then {
        $0.font = .SCDream(size: .subcaption, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .red
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
    private func setupUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(expenseLabel)
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        expenseLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Cell Reuse Preparation
    /// 셀 재사용시 라벨 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        expenseLabel.text = nil
    }
}

