//
//  TopViewController.swift
//  TripLog
//
//  Created by 김석준 on 1/20/25.
//

import UIKit
import SnapKit

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableContainerView = UIView() // 테이블 뷰를 감싸는 컨테이너 뷰
    private let tableView = UITableView()

    // Model 데이터
    private let data = Trip.sampleData() // Model에서 가져옴

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationController?.navigationBar.isHidden = false

        // 네비게이션 타이틀 폰트 크기 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]

        // 초기 네비게이션 바 제목 설정 (첫 번째 여행 제목)
        if let firstTrip = data.first {
            self.navigationItem.title = firstTrip.title
        }

        // 오른쪽 상단에 setIcon 추가
        let setIcon = UIImage(named: "SetIcon") // 프로젝트에 "setIcon" 이미지가 있어야 합니다.
        let setButton = UIBarButtonItem(image: setIcon, style: .plain, target: self, action: #selector(didTapSetIcon))
        navigationItem.rightBarButtonItem = setButton

        setupTableView()
    }

    @objc private func didTapSetIcon() {
        print("Set Icon tapped")
        // 여기서 원하는 동작을 구현하세요
    }

    private func setupTableView() {
        // 테이블 뷰 추가
        view.addSubview(tableView)

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        
        // 구분선 삭제
        tableView.separatorStyle = .none
        
        // SnapKit 레이아웃 설정
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20) // 화면 상단과 간격
            $0.leading.trailing.equalToSuperview() // 좌우 여백
            $0.bottom.equalToSuperview().offset(-20) // 화면 하단과 간격
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell

        let trip = data[indexPath.row]
        cell.configure(
            subtitle: trip.subtitle,
            date: trip.date,
            progress: trip.progress,
            expense: trip.expense,
            budget: trip.budget,
            balance: trip.balance
        )

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀을 선택했을 때
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 선택된 trip 데이터 가져오기
        let selectedTrip = data[indexPath.row]
        
        // 네비게이션 바의 제목을 선택된 trip의 제목으로 설정
        self.navigationItem.title = selectedTrip.title
        
        print("Cell tapped: \(indexPath.row), Title: \(selectedTrip.title)")
    }

}

// MARK: - Custom TableView Cell
class CustomTableViewCell: UITableViewCell {

    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let expenseLabel = UILabel()
    private let budgetLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let balanceLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let todayExpenseButton = UIButton(type: .system)
    private let calendarButton = UIButton(type: .system)

    func configure(subtitle: String, date: String, progress: Float, expense: String, budget: String, balance: String) {
        // 데이터 설정
        subtitleLabel.text = subtitle
        dateLabel.text = date
        expenseLabel.text = "지출: \(expense)"
        budgetLabel.text = "예산: \(budget)"
        
        // 예산과 지출을 숫자로 변환
        let budgetAmount = Int(budget.replacingOccurrences(of: ",", with: "")) ?? 0 // 예산 금액 (콤마 제거)
        let expenseAmount = Int(expense.replacingOccurrences(of: ",", with: "")) ?? 0 // 지출 금액 (콤마 제거)
        
        // 진행률 계산: (지출 / 예산)
        let progressValue = (budgetAmount > 0) ? Float(expenseAmount) / Float(budgetAmount) : 0.0
        progressView.progress = progressValue // progressView의 진행률 업데이트
        
        // 잔액 계산: 예산 - 지출
        let balanceAmount = budgetAmount - expenseAmount
        
        // 잔액 라벨 업데이트 (정수로 표시)
        balanceLabel.text = "잔액: \(balanceAmount)"
        
        setupLayout()
    }

    private func setupLayout() {
        // 모든 서브뷰 추가
        [subtitleLabel, dateLabel, expenseLabel, budgetLabel, progressView, balanceLabel, buttonStackView].forEach {
            contentView.addSubview($0)
        }

        // 버튼 설정
        todayExpenseButton.setTitle("오늘 지출", for: .normal)
        todayExpenseButton.setTitleColor(.black, for: .normal)
        todayExpenseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16) // 글씨 크기와 스타일 설정
        todayExpenseButton.backgroundColor = .clear
        todayExpenseButton.layer.borderColor = UIColor.lightGray.cgColor
        todayExpenseButton.layer.borderWidth = 1

        calendarButton.setTitle("캘린더", for: .normal)
        calendarButton.setTitleColor(.systemBlue, for: .normal)
        calendarButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16) // 글씨 크기와 스타일 설정
        calendarButton.backgroundColor = .clear
        calendarButton.layer.borderColor = UIColor.lightGray.cgColor
        calendarButton.layer.borderWidth = 1

        // 버튼 스택 뷰 설정
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 0 // 버튼 사이 간격 제거
        buttonStackView.distribution = .fillEqually // 버튼 크기를 동일하게 설정
        buttonStackView.addArrangedSubview(todayExpenseButton)
        buttonStackView.addArrangedSubview(calendarButton)

        // 레이아웃 설정
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        progressView.tintColor = .systemBlue
        expenseLabel.font = UIFont.systemFont(ofSize: 10)
        budgetLabel.font = UIFont.systemFont(ofSize: 10)
        budgetLabel.textAlignment = .right
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 12)
        balanceLabel.textAlignment = .right

        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        expenseLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }

        budgetLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(expenseLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()// 버튼의 좌우 여백을 0으로 설정하여 화면 전체를 채움
            $0.height.equalTo(50) // 버튼 높이 설정
        }
    }
}

@available(iOS 17.0, *)
#Preview("TopViewController") {
    UINavigationController(rootViewController: TopViewController())
}
