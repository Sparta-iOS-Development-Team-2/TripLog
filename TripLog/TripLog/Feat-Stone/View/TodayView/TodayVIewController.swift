import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    var onExpenseUpdated: ((String) -> Void)?
    
    private var expenses: [TestTodayExpense] = TestTodayExpense.sampleData()
    
    private let disposeBag = DisposeBag()
    
    private let headerTitleLabel = UILabel().then {
        $0.text = "지출 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
    }
    
    private let helpButton = UIButton(type: .system).then {
        $0.setTitle("?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let totalLabel = UILabel().then {
        $0.text = "오늘 사용 금액"
        $0.font = UIFont.SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    
    private let totalAmountLabel = UILabel().then {
        $0.text = "0 원"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
    }
    
    private let tableView = UITableView().then {
        $0.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        $0.separatorStyle = .none
        $0.applyBackgroundColor()
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0) // ✅ 하단 패딩 추가
    }
    
    // ✅ floatingButton을 UITableView 위에 오버레이
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = UIColor.Personal.normal
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    private let topStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupViews()
        setupConstraints()
        setupFloatingButton() // ✅ Floating Button 추가
        
        tableView.dataSource = self
        tableView.delegate = self
        
        floatingButton.addTarget(self, action: #selector(presentExpenseAddModal), for: .touchUpInside)
        
        updateTotalAmount()
        updateEmptyState()
    }

    @objc private func presentExpenseAddModal() {
        // TODO: 가계부ID를 받아오고 날짜를 지정하는 로직 추가 요청(석준)
        ModalViewManager.showModal(on: self, state: .createNewConsumption(cashBookID: UUID(), date: Date()))
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                let newExpense = TestTodayExpense(
                    date: "2024.01.16",
                    title: "새 지출",
                    category: "기타",
                    amount: "10,000",
                    exchangeRate: "140,444 원"
                )

                self.expenses.append(newExpense)
                self.tableView.reloadData()
                self.updateTotalAmount()

                print("✅ 새로운 지출 내역 추가: \(newExpense)")
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        let headerStackView = UIStackView(arrangedSubviews: [headerTitleLabel, helpButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        
        let totalStackView = UIStackView(arrangedSubviews: [totalLabel, totalAmountLabel]).then {
            $0.axis = .vertical
            $0.alignment = .trailing
            $0.spacing = 4
        }
        
        topStackView.addArrangedSubview(headerStackView)
        topStackView.addArrangedSubview(totalStackView)
        topStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        
        view.addSubview(topStackView)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    /// ✅ floatingButton을 UITableView 위에 추가
    private func setupFloatingButton() {
        view.addSubview(floatingButton)

        floatingButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    /// ✅ **총 금액 업데이트 메서드**
    private func updateTotalAmount() {
        let totalAmount = expenses
            .compactMap { Int($0.exchangeRate.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) }
            .reduce(0, +)

        totalAmountLabel.text = "\(totalAmount) 원"
        onExpenseUpdated?("\(totalAmount)")
    }

    private func updateEmptyState() {
        if expenses.isEmpty {
            let emptyLabel = UILabel().then {
                $0.text = "지출 내역이 없습니다."
                $0.textColor = UIColor(named: "textPlaceholder")
                $0.textAlignment = .center
                $0.font = UIFont.systemFont(ofSize: 16)
            }
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return expenses.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCell.identifier, for: indexPath) as! ExpenseCell
        let expense = expenses[indexPath.section]
        cell.configure(
            date: expense.date,
            title: expense.title,
            category: expense.category,
            amount: expense.amount,
            exchangeRate: expense.exchangeRate
        )
        cell.selectionStyle = .none // 선택 효과 제거
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }

    /// ✅ 커스텀 삭제 버튼을 포함한 스와이프 액션 추가
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 1️⃣ 삭제 버튼을 감싸는 UIView 생성
        let customDeleteView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 120))
        customDeleteView.backgroundColor = .red
        customDeleteView.layer.cornerRadius = 12
        customDeleteView.clipsToBounds = true

        // 2️⃣ 삭제 버튼 추가
        let deleteButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "trash.fill"), for: .normal)
            $0.tintColor = .white
            $0.addTarget(self, action: #selector(deleteExpense(_:)), for: .touchUpInside)
        }

        customDeleteView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        // 3️⃣ UIView를 이미지로 변환
        let deleteImage = UIGraphicsImageRenderer(size: customDeleteView.frame.size).image { _ in
            customDeleteView.drawHierarchy(in: customDeleteView.bounds, afterScreenUpdates: true)
        }

        // 4️⃣ UIContextualAction 생성 (이미지 적용)
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            // ✅ 데이터 삭제
            self.expenses.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            
            // ✅ 총 금액 업데이트
            self.updateTotalAmount()
            
            // ✅ 빈 상태 업데이트
            self.updateEmptyState()

            completionHandler(true) // 완료 핸들러 호출
        }
        
        deleteAction.image = deleteImage
        deleteAction.backgroundColor = UIColor.CustomColors.Background.background

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    /// ✅ 삭제 버튼 액션 (뷰에서 호출되도록 구현)
    @objc private func deleteExpense(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? ExpenseCell,
           let indexPath = tableView.indexPath(for: cell) {
            expenses.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            updateTotalAmount()  // ✅ 삭제 후 총 금액 업데이트
            updateEmptyState()
        }
    }
}

@available(iOS 17.0, *)
#Preview("TodayViewController") {
    let viewController = TodayViewController()
    return UINavigationController(rootViewController: viewController)
}
