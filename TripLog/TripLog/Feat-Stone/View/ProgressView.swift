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
        $0.progressTintColor = .systemBlue   // 진행 상태 색상 (파란색)
        $0.trackTintColor = .white       // 배경색을 하얀색으로 설정
        $0.layer.cornerRadius = 8           // 테두리 둥글게
        $0.layer.borderColor = UIColor.black.cgColor   // 테두리 색상 (검은색)
        $0.layer.borderWidth = 1             // 테두리 두께
        $0.clipsToBounds = true
    }
    
    private let progressLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.text = "0%"  // 초기값 설정
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
        let budgetAmount = Int(budget.replacingOccurrences(of: ",", with: "")) ?? 0
        let expenseAmount = Int(expense.replacingOccurrences(of: ",", with: "")) ?? 0

        let progressValue = (budgetAmount > 0) ? Float(expenseAmount) / Float(budgetAmount) : 0.0
        progressBar.progress = progressValue

        let percentage = Int(progressValue * 100)
        progressLabel.text = "\(percentage)%"

        expenseLabel.text = "지출: \(expense)"
        budgetLabel.text = "예산: \(budget)"
        balanceLabel.text = "잔액: \(budgetAmount - expenseAmount)"
        balanceLabel.textColor = UIColor.Personal.normal

        // 진행 상태에 따라 progressLabel 위치 업데이트
        updateProgressLabelPosition(progressValue)
    }


    private func updateProgressLabelPosition(_ progressValue: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // 진행 상태에 따라 progressLabel의 위치를 계산
            let labelWidth = self.progressLabel.intrinsicContentSize.width
            let progressBarWidth = self.progressBar.bounds.width

            // 이동값 (왼쪽으로 8pt 이동)
            let leftOffset: CGFloat = -12

            // 진행바 끝 위치 계산
            let offsetX = CGFloat(progressValue) * progressBarWidth - labelWidth / 2 + leftOffset

            // 최소값과 최대값으로 제한 (진행바를 벗어나지 않도록)
            let adjustedOffsetX = max(0, min(offsetX, progressBarWidth - labelWidth))

            // progressLabel 위치 업데이트
            self.progressLabel.snp.updateConstraints {
                $0.leading.equalTo(self.progressBar.snp.leading).offset(adjustedOffsetX)
            }

            // 레이아웃 즉시 갱신
            self.layoutIfNeeded()
        }
    }

    private func setupLayout() {
        // 서브뷰 추가
        [expenseLabel, budgetLabel, progressBar, balanceLabel, progressLabel].forEach { addSubview($0) }

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

        // progressLabel 위치 설정
        progressLabel.snp.makeConstraints {
            $0.centerY.equalTo(progressBar)
            $0.leading.equalTo(progressBar.snp.leading) // 초기 위치 설정
        }
    }
}
