import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

class TopViewController: UIViewController {

    private let viewModel: TopViewModel
    private let disposeBag = DisposeBag()

    private let todayViewController: TodayViewController
    private let calendarViewController = CalendarViewController()

    private lazy var switcherView: TripSwitcherView = {
        return TripSwitcherView(todayView: todayViewController.view, calendarView: calendarViewController.view)
    }()

    private lazy var tripSummaryView = TripLogNewView(switcherView: switcherView)

    private lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = false
        $0.rowHeight = self.view.bounds.height
        $0.applyBackgroundColor()
    }

    init(cashBook: MockCashBookModel) {
        self.viewModel = TopViewModel(cashBook: cashBook)
        self.todayViewController = TodayViewController(cashBookID: cashBook.id)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupUI()
        setupTableView()
        setupTripSummary()
        bindTodayViewController() // ✅ `TodayViewController`의 totalExpense 업데이트 바인딩
    }

    private func setupUI() {
        view.applyBackgroundColor()
        
        navigationController?.navigationBar.isHidden = false

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
        self.navigationItem.title = viewModel.sections.value.first?.items.first?.tripName ?? "여행"
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.tableHeaderView = tripSummaryView
    }

    private func setupTripSummary() {
        guard let cashBook = viewModel.sections.value.first?.items.first else { return }

        tripSummaryView.configure(
            subtitle: cashBook.note,
            date: "\(cashBook.departure) ~ \(cashBook.homecoming)",
            budget: "\(NumberFormatter.formattedString(from: cashBook.budget)) 원",
            todayVC: todayViewController
        )

        let headerSize = tripSummaryView.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        )
        tripSummaryView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerSize.height)

        tableView.tableHeaderView = tripSummaryView
    }

    /// ✅ `TodayViewController`에서 `totalExpense` 값을 받아 `tripSummaryView` 업데이트
    private func bindTodayViewController() {
        todayViewController.onTotalExpenseUpdated = { [weak self] totalExpense in
            guard let self = self else { return }
            
            // ✅ `tripSummaryView`의 `progressView` 업데이트
            self.tripSummaryView.updateExpense(totalExpense)
        }
    }
}
