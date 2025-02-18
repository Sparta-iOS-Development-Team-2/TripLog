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

    let expense = BehaviorRelay<Int>(value: 0)

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

    func setBudget(_ budget: Int) {
        budgetAmount = budget
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budgetAmount))"
    }

    private func bindExpense() {
        expense
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, expense in

                // ✅ 3. 잔액 계산 및 출력
                let balance = owner.budgetAmount - expense
                owner.balanceRelay.accept(balance)
                debugPrint("✅ budgetAmount: \(owner.budgetAmount), balance 계산 값: \(balance)")

                // ✅ 4. 포맷된 잔액 확인
                let formattedBalance = NumberFormatter.wonFormat(balance)
                debugPrint("✅ formattedBalance: \(formattedBalance)")

                // ✅ 5. UI 업데이트 전 출력
                let formattedExpense = NumberFormatter.wonFormat(expense)
                debugPrint("✅ formattedExpense: \(formattedExpense)")
                
                owner.expenseLabel.text = "지출: \(formattedExpense)"
                owner.balanceLabel.text = "잔액: \(formattedBalance)"
                owner.balanceLabel.textColor = (balance < 0) ? .red : .CustomColors.Accent.blue

                // ✅ 6. Progress Bar 값 확인
                let progressValue: CGFloat = (owner.budgetAmount > 0) ? CGFloat(expense) / CGFloat(owner.budgetAmount) : 0.0
                debugPrint("✅ Progress Bar Value: \(progressValue)")

                owner.progressBar.updateProgress(progressValue) // ✅ 프로그레스 업데이트
            }
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
