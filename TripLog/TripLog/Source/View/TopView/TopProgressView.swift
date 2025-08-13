import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TopProgressView: UIView {
    
    // MARK: - Rx Properties
    
    private var disposeBag = DisposeBag()
    private let balanceRelay = PublishRelay<Int>()
    private let expense = BehaviorRelay<Int>(value: 0)
    
    private var budgetAmount: Int = 0
    
    // MARK: - UI Components
    
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
    
    // MARK: - Inintializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindExpense()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        bindExpense()
    }
    
    func setProgress(_ budget: Int, _ amount: Int) {
        budgetAmount = budget == 0 ? 1 : budget
        budgetLabel.text = "예산: \(NumberFormatter.wonFormat(budget))"
        
        expense.accept(amount)
    }
    
    func updateProgress(_ amount: Int) {
        expense.accept(amount)
    }
}

private extension TopProgressView {
    func bindExpense() {
        expense
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, expense in
                
                // ✅ 3. 잔액 계산 및 출력
                let checkBudget = owner.budgetLabel.text == "예산: 0 원"
                let balance = checkBudget ? 0 - expense : owner.budgetAmount - expense
                owner.balanceRelay.accept(balance)
                
                // ✅ 4. 포맷된 잔액 확인
                let formattedBalance = NumberFormatter.wonFormat(balance)
                
                // ✅ 5. UI 업데이트 전 출력
                let formattedExpense = NumberFormatter.wonFormat(expense)
                
                owner.expenseLabel.text = "지출: \(formattedExpense)"
                owner.balanceLabel.text = "잔액: \(formattedBalance)"
                owner.balanceLabel.textColor = (balance < 0) ? .red : .CustomColors.Accent.blue
                
                // ✅ 6. Progress Bar 값 확인
                let progressValue: CGFloat = (owner.budgetAmount > 0) ? CGFloat(expense) / CGFloat(owner.budgetAmount) : 0.0
                
                owner.progressBar.updateProgress(progressValue) // ✅ 프로그레스 업데이트
            }
            .disposed(by: disposeBag)
    }
    
    
    func setupLayout() {
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
