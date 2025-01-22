//
//  ProgressBarView.swift
//  TripLog
//
//  Created by 김석준 on 1/22/25.
//
import UIKit
import SnapKit
import Then

class ProgressView: UIView {

    private let progressBar = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = .systemBlue
        $0.trackTintColor = .lightGray
    }
    private let expenseLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        $0.textColor = .black
    }
    private let budgetLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        $0.textColor = .black
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
        // 예산과 지출을 숫자로 변환
        let budgetAmount = Int(budget.replacingOccurrences(of: ",", with: "")) ?? 0
        let expenseAmount = Int(expense.replacingOccurrences(of: ",", with: "")) ?? 0

        // 진행률 계산
        let progressValue = (budgetAmount > 0) ? Float(expenseAmount) / Float(budgetAmount) : 0.0
        progressBar.progress = progressValue

        // 라벨 업데이트
        expenseLabel.text = "지출: \(expense)"
        budgetLabel.text = "예산: \(budget)"
        balanceLabel.text = "잔액: \(budgetAmount - expenseAmount)"

        // 색상 설정 (컬러 로드 실패 시 기본값 사용)
        balanceLabel.textColor = UIColor.Personal.normal
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
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
