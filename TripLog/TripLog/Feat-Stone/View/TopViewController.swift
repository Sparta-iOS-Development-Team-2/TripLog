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
        $0.applyBackgroundColor()
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.rowHeight = 192
        $0.estimatedRowHeight = 0
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = false
    }

    private let data = TestDummyData.sampleData() // Model에서 가져옴

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyBackgroundColor()

        navigationController?.navigationBar.isHidden = false

        // 네비게이션 타이틀 폰트 크기 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]

        if let firstTrip = data.first {
            self.navigationItem.title = firstTrip.title
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UIScreen.main.bounds.height * 0.5

        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.applyBackgroundColor()
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
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedTrip = data[indexPath.row]
        self.navigationItem.title = selectedTrip.title

        print("Cell tapped: \(indexPath.row), Title: \(selectedTrip.title)")
    }
}

@available(iOS 17.0, *)
#Preview("TopViewController") {
    UINavigationController(rootViewController: TopViewController())
}
