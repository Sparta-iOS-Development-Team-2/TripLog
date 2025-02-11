import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class TopProgressView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let progressBar = CustomProgressView()
    
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

    let expense = BehaviorRelay<String>(value: "0 원")

    private var budgetAmount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindExpense()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        bindExpense()
    }

    func setBudget(_ budget: String) {
        budgetAmount = Int(budget.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budgetAmount))"
    }

    private func bindExpense() {
        expense
            .subscribe(onNext: { [weak self] expenseText in
                guard let self = self else { return }
                
                // ✅ 1. Rx 스트림에서 받은 원본 데이터 확인
                print("🔹 expenseText (원본): \(expenseText)")

                // ✅ 2. 숫자 값으로 변환된 지출 금액 확인
                let expenseAmount = Int(expenseText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                print("✅ expenseAmount (숫자 변환 후): \(expenseAmount)")

                // ✅ 3. 잔액 계산 및 출력
                let balance = self.budgetAmount - expenseAmount
                print("✅ budgetAmount: \(self.budgetAmount), balance 계산 값: \(balance)")

                // ✅ 4. 포맷된 잔액 확인
                let formattedBalance = NumberFormatter.wonFormat(balance)
                print("✅ formattedBalance: \(formattedBalance)")

                // ✅ 5. UI 업데이트 전 출력
                let formattedExpense = NumberFormatter.wonFormat(expenseAmount)
                print("✅ formattedExpense: \(formattedExpense)")
                
                self.expenseLabel.text = "지출: \(formattedExpense)"
                self.balanceLabel.text = "잔액: \(formattedBalance)"
                self.balanceLabel.textColor = (balance < 0) ? .red : UIColor.Personal.normal

                // ✅ 6. Progress Bar 값 확인
                let progressValue = (self.budgetAmount > 0) ? Float(expenseAmount) / Float(self.budgetAmount) : 0.0
                print("✅ Progress Bar Value: \(progressValue)")

                self.progressBar.updateProgress(CGFloat(progressValue)) // ✅ 프로그레스 업데이트
            })
            .disposed(by: disposeBag)
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
            $0.height.equalTo(16).priority(.required)
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.low)
        }
    }
}
