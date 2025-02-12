import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TopProgressView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let progressBar = CustomProgressView()
    
    let balanceRelay = PublishRelay<Int>()
    
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
                debugPrint("🔹 expenseText (원본): \(expenseText)")

                // ✅ 2. 숫자 값으로 변환된 지출 금액 확인
                let expenseAmount = Int(expenseText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0
                debugPrint("✅ expenseAmount (숫자 변환 후): \(expenseAmount)")

                // ✅ 3. 잔액 계산 및 출력
                let balance = self.budgetAmount - expenseAmount
                self.balanceRelay.accept(balance)
                debugPrint("✅ budgetAmount: \(self.budgetAmount), balance 계산 값: \(balance)")

                // ✅ 4. 포맷된 잔액 확인
                let formattedBalance = NumberFormatter.wonFormat(balance)
                debugPrint("✅ formattedBalance: \(formattedBalance)")

                // ✅ 5. UI 업데이트 전 출력
                let formattedExpense = NumberFormatter.wonFormat(expenseAmount)
                debugPrint("✅ formattedExpense: \(formattedExpense)")
                
                self.expenseLabel.text = "지출: \(formattedExpense)"
                self.balanceLabel.text = "잔액: \(formattedBalance)"
                self.balanceLabel.textColor = (balance < 0) ? .red : UIColor.Personal.normal

                // ✅ 6. Progress Bar 값 확인
                let progressValue: CGFloat = (self.budgetAmount > 0) ? CGFloat(expenseAmount) / CGFloat(self.budgetAmount) : 0.0
                debugPrint("✅ Progress Bar Value: \(progressValue)")

                self.progressBar.updateProgress(progressValue) // ✅ 프로그레스 업데이트
            })
            .disposed(by: disposeBag)
    }


    private func setupLayout() {
        [expenseLabel, budgetLabel, progressBar, balanceLabel].forEach { addSubview($0) }

        expenseLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(18)
        }

        budgetLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }

        progressBar.snp.makeConstraints {
            $0.top.equalTo(expenseLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(16)
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressBar.snp.bottom)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
    }
}
