import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class TopProgressView: UIView {
    
    private let disposeBag = DisposeBag()
    
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
                
                let expenseAmount = Int(expenseText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                let balance = self.budgetAmount - expenseAmount
                let formattedBalance = NumberFormatter.wonFormat(balance)

                self.expenseLabel.text = "지출: \(NumberFormatter.wonFormat(expenseAmount))"
                self.balanceLabel.text = "잔액: \(formattedBalance)"
                self.balanceLabel.textColor = (balance < 0) ? .red : UIColor.Personal.normal
                
                let progressValue = (self.budgetAmount > 0) ? Float(expenseAmount) / Float(self.budgetAmount) : 0.0
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
            $0.height.equalTo(16)
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
