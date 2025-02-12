//
//  CalendarExpenseCell.swift
//  TripLog
//
//  Created by Jamong on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

/// 지출 항목을 표시하는 테이블뷰 셀
/// - 지출 항목명과 외화 금액을 상단에 표시
/// - 카테고리/결제수단과 원화 환산액을 하단에 표시
/// - 다크모드 대응을 위한 동적 색상 처리
final class CalendarExpenseCell: UITableViewCell {
    // MARK: - UI Components
    /// 지출 항목명을 표시하는 레이블
    private let titleLabel = UILabel().then {
        $0.font = .SCDream(size: .headline, weight: .bold)
        $0.textColor = UIColor.CustomColors.Text.textPrimary
    }
    
    /// 외화 금액을 표시하는 레이블
    private let foreignAmountLabel = UILabel().then {
        $0.font = .SCDream(size: .headline, weight: .bold)
        $0.textAlignment = .right
        $0.textColor = UIColor.CustomColors.Text.textPrimary
    }
    
    /// 카테고리와 결제수단을 표시하는 레이블
    private let categoryLabel = UILabel().then {
        $0.font = .SCDream(size: .caption, weight: .regular)
        $0.textColor = UIColor.CustomColors.Text.textSecondary
    }
    
    /// 원화 환산 금액을 표시하는 레이블
    private let wonAmountLabel = UILabel().then {
        $0.font = .SCDream(size: .caption, weight: .regular)
        $0.textAlignment = .right
        $0.textColor = UIColor.CustomColors.Accent.blue
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    /// UI 컴포넌트들의 초기 설정
    private func setupUI() {
        backgroundColor = UIColor.CustomColors.Background.background
        selectionStyle = .none
        
        [titleLabel, foreignAmountLabel, categoryLabel, wonAmountLabel].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    /// UI 컴포넌트들의 제약조건 설정
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(foreignAmountLabel.snp.leading).offset(-8)
        }
        
        foreignAmountLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        wonAmountLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryLabel)
            $0.trailing.equalTo(foreignAmountLabel)
        }
    }
    
    // MARK: - Configuration
    /// 셀의 데이터를 설정하는 메서드
    /// - Parameter item: 표시할 지출 항목 데이터
    /// - Note: 외화 금액은 통화 종류에 따라 다른 형식으로 표시
    ///   (JPY, CNY는 정수로, 다른 통화는 소수점 포함)
    func configure(with model: MockMyCashBookModel) {
        titleLabel.text = model.note
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        // 변경 예정 model.country -> Symbol
        let formattedAmount = numberFormatter.string(from: NSNumber(value: model.amount)) ?? "0"
        foreignAmountLabel.text = "\(model.country) \(formattedAmount)"
        
        categoryLabel.text = "\(model.category) / \(model.payment ? "카드" : "현금")"
        
        // calculatedAmount 들어오면 넣을 예정
        let formattedWonAmount = numberFormatter.string(from: NSNumber(value: Int(model.caculatedAmount))) ?? "0"
        wonAmountLabel.text = "\(formattedWonAmount)원"
    }
    
    /// 셀이 재사용될 때 모든 상태를 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        foreignAmountLabel.text = nil
        categoryLabel.text = nil
        wonAmountLabel.text = nil
    }
}
