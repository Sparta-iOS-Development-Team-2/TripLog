//
//  CalendarExpenseListHeaderView.swift
//  TripLog
//
//  Created by Jamong on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

/// 지출 목록의 헤더를 표시하는 커스텀 뷰
/// - 날짜, 총 지출액, 잔액 표시
/// - 지출 추가 버튼 포함
final class CalendarExpenseListHeaderView: UIView {
        
    // MARK: - UI Components
    /// 날짜와 추가 버튼을 담는 스택뷰
    private let topStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    /// 지출과 잔액 정보를 담는 스택뷰
    private let bottomStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    /// 지출 정보를 담는 스택뷰
    private let expenseStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    /// 잔액 정보를 담는 스택뷰
    private let balanceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    /// 선택된 날짜를 표시하는 레이블
    fileprivate let dateLabel = UILabel().then {
        $0.font = .SCDream(size: .display, weight: .bold)
        $0.textColor = UIColor.CustomColors.Text.textPrimary
    }
    
    /// 지출 추가 버튼
    fileprivate let addButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.CustomColors.Accent.blue
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        config.image = UIImage(systemName: "plus")?
            .applyingSymbolConfiguration(imageConfig)
        
        config.baseForegroundColor = UIColor.CustomColors.Background.detailBackground
        config.attributedTitle = AttributedString("추가하기", attributes: AttributeContainer([
            .font: UIFont.SCDream(size: .headline, weight: .medium)
        ]))
        
        $0.configuration = config
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let expenseTitleLabel = UILabel().then {
        $0.text = "지출"
        $0.font = .SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor.CustomColors.Text.textPrimary
    }
    
    private let expenseAmountLabel = UILabel().then {
        $0.font = .SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor.CustomColors.Text.textPrimary
    }
    
    private let balanceTitleLabel = UILabel().then {
        $0.text = "잔액"
        $0.font = .SCDream(size: .body, weight: .medium)
        $0.textAlignment = .right
        $0.textColor = UIColor.CustomColors.Accent.blue
    }
    
    private let balanceAmountLabel = UILabel().then {
        $0.font = .SCDream(size: .body, weight: .medium)
        $0.textAlignment = .right
        $0.textColor = UIColor.CustomColors.Accent.blue
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        setupStackViews()
        setupConstraints()
    }
    
    private func setupStackViews() {
        // 스택뷰 구성
        addSubview(topStackView)
        addSubview(bottomStackView)
        
        // 상단 스택뷰 구성
        topStackView.addArrangedSubview(dateLabel)
        topStackView.addArrangedSubview(addButton)
        
        // 하단 스택뷰 구성
        bottomStackView.addArrangedSubview(expenseStackView)
        bottomStackView.addArrangedSubview(balanceStackView)
        
        // 지출 스택뷰 구성
        expenseStackView.addArrangedSubview(expenseTitleLabel)
        expenseStackView.addArrangedSubview(expenseAmountLabel)
        
        // 잔액 스택뷰 구성
        balanceStackView.addArrangedSubview(balanceTitleLabel)
        balanceStackView.addArrangedSubview(balanceAmountLabel)
    }
    
    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
    
    func configure(date: Date, expense: Double, balance: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 지출"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        
        let formattedExpense = numberFormatter.string(from: NSNumber(value: expense)) ?? "0"
        let formattedBalance = numberFormatter.string(from: NSNumber(value: balance)) ?? "0"
        
        dateLabel.text = formatter.string(from: date)
        expenseAmountLabel.text = "\(formattedExpense)원"
        balanceAmountLabel.text = "\(formattedBalance)원"
    }
}

extension Reactive where Base: CalendarExpenseListHeaderView {
    var addButtonTapped: Observable<Void> {
        base.addButton.rx.tap.asObservable()
    }
}
