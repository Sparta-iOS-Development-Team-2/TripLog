//
//  CalendarExpenseView.swift
//  TripLog
//
//  Created by Jamong on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

/// 캘린더의 지출 목록을 표시하는 커스텀 뷰
/// - 지출 내역 헤더와 목록을 포함
/// - 선택된 날짜의 지출 정보 표시
final class CalendarExpenseView: UIView {
    // MARK: - UI Components
    /// 지출 내역의 헤더를 표시하는 뷰
    fileprivate let headerView = CalendarExpenseListHeaderView()
    
    /// 지출 목록을 표시하는 테이블뷰
    let tableView = UITableView().then {
        $0.register(CalendarExpenseCell.self, forCellReuseIdentifier: "CalendarExpenseCell")
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.estimatedRowHeight = 80
        $0.rowHeight = UITableView.automaticDimension
    }
    
    /// 데이터가 없을 때 표시되는 빈 상태 뷰
    private let emptyStateLabel = UILabel().then {
        $0.text = "지출 내역이 없습니다"
        $0.font = .SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor.CustomColors.Text.textSecondary
        $0.textAlignment = .center
    }

    // MARK: - Properties
    /// 현재 표시중인 지출 항목 배열
    private var expenses: [MockMyCashBookModel] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    /// UI 컴포넌트들의 초기 설정
    private func setupUI() {
        [headerView, tableView, emptyStateLabel].forEach { addSubview($0) }
        
        setupConstraints()
        setupTableView()
    }
    
    /// UI 컴포넌트들의 제약조건 설정
    private func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(60).priority(.low)
//            $0.height.equalTo(tableView.contentSize.height).priority(.high)
            $0.bottom.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(tableView)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    /// 테이블뷰 초기 설정
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Public Methods
    /// 뷰의 데이터를 설정하는 메서드
    /// - Parameters:
    ///   - date: 선택된 날짜
    ///   - expenses: 해당 날짜의 지출 항목 배열
    ///   - balance: 현재 잔액
    func configure(date: Date, expenses: [MockMyCashBookModel], balance: Int) {
        self.expenses = expenses
        let totalExpense = Int(expenses.reduce(0) { $0 + $1.amount })
        headerView.configure(date: date, expense: totalExpense, balance: balance)
        
        // 데이터 유무에 따라 빈 상태 표시
        emptyStateLabel.isHidden = !expenses.isEmpty
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarExpenseView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarExpenseCell", for: indexPath) as? CalendarExpenseCell else {
            return UITableViewCell()
        }
        
        let expense = expenses[indexPath.row]
        cell.configure(with: expense)
        
        return cell
    }
}

extension Reactive where Base: CalendarExpenseView {
    var addButtondTapped: Observable<Void> {
        base.headerView.rx.addButtonTapped
    }
}
