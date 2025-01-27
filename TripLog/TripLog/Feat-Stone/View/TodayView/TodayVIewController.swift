import UIKit
import SnapKit
import Then

class TodayViewController: UIViewController {
    
    // Dummy Data
    private var expenses: [TestTodayExpense] = TestTodayExpense.sampleData()
    
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
        $0.textColor = .gray
    }
    
    private let totalAmountLabel = UILabel().then {
        $0.text = "1,000,000 원"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
    }
    
    private let tableView = UITableView().then {
        $0.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        $0.separatorStyle = .none
        $0.backgroundColor = .white
    }
    
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = UIColor.Personal.normal
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    private let floatingButtonBackground = UIView().then {
        $0.backgroundColor = UIColor.Personal.normal
        $0.layer.cornerRadius = 21.5
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    private let topStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateEmptyState()
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
        view.addSubview(floatingButtonBackground)
        view.addSubview(floatingButton)
    }
    
    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(floatingButtonBackground.snp.top).offset(-16) // 버튼과 테이블 뷰 간격 추가
        }
        
        floatingButtonBackground.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(43)
        }
        
        floatingButton.snp.makeConstraints {
            $0.center.equalTo(floatingButtonBackground)
            $0.width.height.equalTo(64)
        }
    }
    
    private func updateEmptyState() {
        if expenses.isEmpty {
            let emptyLabel = UILabel().then {
                $0.text = "지출 내역이 없습니다."
                $0.textColor = .gray
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택 효과 제거
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4 // 기존 4에서 8로 수정하여 삭제 버튼과 다른 셀 간격 추가
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView().then {
            $0.backgroundColor = .clear // 투명한 배경으로 간격만 추가
        }
        return footerView
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            // 커스텀 삭제 뷰 생성
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.expenses.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            self.updateEmptyState()
            completionHandler(true)
        }
            
        // 삭제 버튼 커스텀 설정
        deleteAction.backgroundColor = .white // 배경색 제거
            
        // 삭제 버튼의 커스텀 뷰 생성
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 120)) // UIView 크기 설정
        customView.backgroundColor = .red // 배경색을 흰색으로 설정
        customView.layer.cornerRadius = 8
        customView.clipsToBounds = true

            
        let deleteButton = UIButton(type: .system).then {
            $0.setImage(UIImage(systemName: "trash"), for: .normal)
            $0.tintColor = .white
            $0.addTarget(self, action: #selector(deleteExpense(_:)), for: .touchUpInside)
        }
            
        customView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24) // 아이콘 크기 설정
        }
            
        // 삭제 버튼을 이미지로 렌더링
        deleteAction.image = UIGraphicsImageRenderer(size: customView.frame.size).image { _ in
            customView.drawHierarchy(in: customView.bounds, afterScreenUpdates: true)
        }
            
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    @objc private func deleteExpense(_ sender: UIButton) {
        if let indexPath = tableView.indexPath(for: sender.superview?.superview as! UITableViewCell) {
            expenses.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            updateEmptyState()
        }
    }
}

@available(iOS 17.0, *)
#Preview("TodayViewController") {
    let viewController = TodayViewController()
    return UINavigationController(rootViewController: viewController)
}
