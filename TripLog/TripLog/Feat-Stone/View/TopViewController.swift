import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

class TopViewController: UIViewController {

    private let viewModel: TopViewModel
    private let disposeBag = DisposeBag()

    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = UIScreen.main.bounds.height * 0.5
    }

    // ✅ RxDataSources에서 사용할 데이터소스 생성
    private let dataSource = RxTableViewSectionedReloadDataSource<CashBookSection>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
            cell.configure(
                subtitle: item.note,
                date: "\(item.departure) ~ \(item.homecoming)",
                budget: "\(item.budget) 원",
                cashBookID: item.id
            )
            return cell
        }
    )

    // ✅ `context` 없이 UUID 및 개별 데이터만 받도록 수정
    init(cashBook: MockCashBookModel) {
        self.viewModel = TopViewModel(cashBook: cashBook)
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
        
        setupUI()
        setupTableView()
        bindViewModel() // ✅ Rx 바인딩 실행
    }

    // ✅ UI 관련 설정
    private func setupUI() {
        view.applyBackgroundColor()
        
        navigationController?.navigationBar.isHidden = false

        // 네비게이션 타이틀을 tripName으로 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
        self.navigationItem.title = viewModel.sections.value.first?.items.first?.tripName ?? "여행"
    }

    // ✅ UITableView 설정
    private func setupTableView() {
        view.addSubview(tableView)

        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // ✅ ViewModel 바인딩 (RxDataSources)
    private func bindViewModel() {
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource)) // ✅ Rx 방식으로 데이터 바인딩
            .disposed(by: disposeBag)

        // ✅ 선택한 셀 이벤트 감지
        tableView.rx.modelSelected(MockCashBookModel.self)
            .subscribe(onNext: { [weak self] selectedCashBook in
                print("📌 Selected trip: \(selectedCashBook.tripName)")
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview("TopViewController") {
    let sampleCashBook = MockCashBookModel(
        id: UUID(),
        tripName: "제주도 여행",
        note: "제주에서 3박 4일 일정",
        budget: 500000,
        departure: "2025-01-20",
        homecoming: "2025-01-24"
    )

    return UINavigationController(
        rootViewController: TopViewController(cashBook: sampleCashBook)
    )
}
