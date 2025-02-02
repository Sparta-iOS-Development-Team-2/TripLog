//
//  TopViewController.swift
//  TripLog
//
//  Created by 김석준 on 1/20/25.
//

import UIKit
import SnapKit
import Then

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor.CustomColors.Background.background
    }

    // Model 데이터
    private let data = TestDummyData.sampleData() // Model에서 가져옴

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.CustomColors.Background.background

        navigationController?.navigationBar.isHidden = false

        // 네비게이션 타이틀 폰트 크기 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]

        // 초기 네비게이션 바 제목 설정 (첫 번째 여행 제목)
        if let firstTrip = data.first {
            self.navigationItem.title = firstTrip.title
        }

        setupTableView()
    }

    private func setupTableView() {
        // 테이블 뷰 추가
        view.addSubview(tableView)

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")

        // SnapKit 레이아웃 설정
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
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
            expense: trip.expense,
            budget: trip.budget
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

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()

    func configure(subtitle: String, date: String, expense: String, budget: String) {
        // 데이터 설정
        titleDateView.configure(subtitle: subtitle, date: date)
        progressView.configure(expense: expense, budget: budget)

        setupLayout()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // 모든 서브뷰 추가
        [titleDateView, progressView, buttonStackView].forEach {
            contentView.addSubview($0)
        }

        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
}

//@available(iOS 17.0, *)
//#Preview("TopViewController") {
//    UINavigationController(rootViewController: TopViewController())
//}
