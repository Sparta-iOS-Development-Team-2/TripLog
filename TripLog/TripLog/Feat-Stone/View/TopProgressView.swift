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

    // ✅ **Rx로 관리되는 총 지출 금액 (TopViewController에서 바인딩 가능)**
    let expense = BehaviorRelay<String>(value: "0 원")

    private var budgetAmount: Int = 0 // ✅ 예산 금액 (초기 한 번 설정)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindExpense() // ✅ **Rx 값 변경 시 UI 자동 업데이트**
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        bindExpense() // ✅ **Rx 값 변경 시 UI 자동 업데이트**
    }

    // ✅ **예산 한 번만 설정**
    func setBudget(_ budget: String) {
        budgetAmount = Int(budget.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budgetAmount))"
    }

    // ✅ **Rx로 expense 값 변경될 때 자동 UI 업데이트**
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
                self.progressBar.updateProgress(CGFloat(progressValue))
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
