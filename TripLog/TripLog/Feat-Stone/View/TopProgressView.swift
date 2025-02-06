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
        let budgetAmount = Int(budget.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
        let expenseAmount = Int(expense.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
            
        let balance = budgetAmount - expenseAmount
        let formattedBalance = NumberFormatter.wonFormat(balance)

        expenseLabel.text = "지출: \(NumberFormatter.wonFormat(expenseAmount))"
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budgetAmount))"
        balanceLabel.text = "잔액: \(formattedBalance)"

        balanceLabel.textColor = (balance < 0) ? .red : UIColor.Personal.normal

        let progressValue = (budgetAmount > 0) ? Float(expenseAmount) / Float(budgetAmount) : 0.0
        progressBar.updateProgress(CGFloat(progressValue))
    }

    private func setupLayout() {
        [expenseLabel, budgetLabel, progressBar, balanceLabel].forEach { addSubview($0) }

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
