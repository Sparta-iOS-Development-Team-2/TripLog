//
//  TopViewController.swift
//  TripLog
//
//  Created by 김석준 on 1/20/25.
//

import UIKit
import SnapKit
import Then
import CoreData

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

    private let context: NSManagedObjectContext // CoreData 컨텍스트

    // 추가된 프로퍼티
    private let tripName: String
    private let note: String
    private let budget: Double
    private let period: String

    // `init`을 수정하여 데이터 전달받도록 변경
    init(context: NSManagedObjectContext, tripName: String, note: String, budget: Double, period: String) {
        self.context = context
        self.tripName = tripName
        self.note = note
        self.budget = budget
        self.period = period
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true) // 항상 내비게이션 바 보이기
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyBackgroundColor()

        // 네비게이션 타이틀을 tripName으로 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
        self.navigationItem.title = tripName

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
        return 1 // 단일 데이터 표시
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell

        // `configure`에 전달할 데이터 적용
        cell.configure(
            subtitle: note,
            date: period,
            expense: "", // 필요하면 추가
            budget: "\(budget) 원",
            context: context
        )

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Selected trip: \(tripName)")
    }
}

@available(iOS 17.0, *)
#Preview("TopViewController") {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    return UINavigationController(
        rootViewController: TopViewController(
            context: context,
            tripName: "제주도 여행",
            note: "제주에서 3박 4일 일정",
            budget: 500000,
            period: "2025-01-20 ~ 2025-01-24"
        )
    )
}
