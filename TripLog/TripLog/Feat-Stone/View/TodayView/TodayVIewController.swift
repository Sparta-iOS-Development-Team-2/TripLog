//
//  ExpenseCell.swift
//  TripLog
//
//  Created by 김석준 on 1/24/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    // Dummy Data
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
    }
    
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = UIColor.Personal.normal
    }
    
    private let topStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupViews()
        setupConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        floatingButton.addTarget(self, action: #selector(presentExpenseAddModal), for: .touchUpInside)
        
        updateTotalAmount()
        updateEmptyState()
    }

    @objc private func presentExpenseAddModal() {
        ModalViewManager.showModal(on: self, state: .createNewbudget)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                // ✅ 기본값으로 새로운 지출 항목 생성
                let newExpense = TestTodayExpense(
                    date: "2024.01.16",  // 현재 날짜
                    title: "새 지출",     // 기본 제목
                    category: "기타",     // 기본 카테고리
                    amount: "10,000",     // 기본 금액
                    exchangeRate: "140,444 원"
                )

                // ✅ 배열에 추가하고 UI 업데이트
                self.expenses.append(newExpense)
                self.tableView.reloadData()
                self.updateTotalAmount()  // ✅ 총 금액 업데이트

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
            $0.bottom.equalTo(floatingButton.snp.top).offset(-16)
        }
        
        floatingButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(64)
        }
    }
    
    /// ✅ **총 금액 업데이트 메서드**
    private func updateTotalAmount() {
        let totalAmount = expenses
            .compactMap { Int($0.amount.replacingOccurrences(of: ",", with: "")) } // 숫자로 변환
            .reduce(0, +) // 합산
        totalAmountLabel.text = "\(totalAmount) 원"
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

    @objc private func deleteExpense(_ sender: UIButton) {
        if let indexPath = tableView.indexPath(for: sender.superview?.superview as! UITableViewCell) {
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
