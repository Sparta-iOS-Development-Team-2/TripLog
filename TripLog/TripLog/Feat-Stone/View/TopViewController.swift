import UIKit
import SnapKit
import Then
import CoreData

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let context: NSManagedObjectContext
    private let cashBook: MockCashBookModel

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

    // ✅ 데이터 전달을 위해 MockCashBookModel을 받는 init 추가
    init(context: NSManagedObjectContext, cashBook: MockCashBookModel) {
        self.context = context
        self.cashBook = cashBook
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
        self.navigationItem.title = cashBook.tripName

        print("전달된 여행 정보: \(cashBook)")

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

        // ✅ `configure`에 `cashBookID` 추가
        cell.configure(
            subtitle: cashBook.note,
            date: "\(cashBook.departure) ~ \(cashBook.homecoming)",
            expense: "", // 필요하면 추가
            budget: "\(cashBook.budget) 원",
            context: context,
            cashBookID: cashBook.id // ✅ `cashBookID` 추가
        )

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Selected trip: \(cashBook.tripName)")
    }
}

//extension TopViewController {
//    static let fixedUUID = UUID() // 🔹 프리뷰에서 재사용할 고정된 UUID
//}


@available(iOS 17.0, *)
#Preview("TopViewController") {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let sampleCashBookID = UUID() // ✅ 고정된 UUID 사용

    let sampleCashBook = MockCashBookModel(
        id: sampleCashBookID, // ✅ UUID 유지
        tripName: "제주도 여행",
        note: "제주에서 3박 4일 일정",
        budget: 500000,
        departure: "2025-01-20",
        homecoming: "2025-01-24"
    )

    return UINavigationController(
        rootViewController: TopViewController(
            context: context,
            cashBook: sampleCashBook
        )
    )
}



