//
//  ProgressBarView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//
import UIKit
import SnapKit
import Then

class TopProgressView: UIView {

    private let progressBar = CustomProgressView()

    private let expenseLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    private let budgetLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
        $0.textAlignment = .right
    }
    private let balanceLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(expense: String, budget: String) {
        // 숫자로 변환 (천 단위 콤마 제거)
        let budgetAmount = Int(budget.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
        let expenseAmount = Int(expense.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
            
        // 잔액 계산
        let balance = budgetAmount - expenseAmount
        let formattedBalance = NumberFormatter.wonFormat(balance) // "1,000원" 형식으로 변환

        // UI 업데이트
        expenseLabel.text = "지출: \(NumberFormatter.wonFormat(expenseAmount))"
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budgetAmount))"
        balanceLabel.text = "잔액: \(formattedBalance)"

        // 잔액이 0보다 작으면 빨간색으로 표시 (예산 초과)
        balanceLabel.textColor = (balance < 0) ? .red : UIColor.Personal.normal

        // 프로그레스 바 업데이트
        let progressValue = (budgetAmount > 0) ? Float(expenseAmount) / Float(budgetAmount) : 0.0
        progressBar.updateProgress(CGFloat(progressValue))
    }

    private func setupLayout() {
        // 서브뷰 추가
        [expenseLabel, budgetLabel, progressBar, balanceLabel].forEach { addSubview($0) }

        // 레이아웃 설정
        expenseLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        budgetLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
        }

        progressBar.snp.makeConstraints {
            $0.top.equalTo(expenseLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(16)
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
