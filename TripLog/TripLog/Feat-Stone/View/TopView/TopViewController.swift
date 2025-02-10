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
//        $0.backgroundColor = UIColor.CustomColors.Background.detailBackground
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
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(tripSummaryView)

        tripSummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top) // ✅ safeArea의 상단 맞추기
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // ✅ safeArea의 하단까지 확장
        }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            let initialTotalExpense = self.todayViewController.viewModel.totalExpenseRelay.value
        }
    }

    private func setupTripSummary() {
        guard let cashBook = viewModel.sections.value.first?.items.first else { return }

        tripSummaryView.configure(
            subtitle: cashBook.note,
            date: "\(cashBook.departure.formattedDate()) - \(cashBook.homecoming.formattedDate())",
            budget: "\(NumberFormatter.formattedString(from: cashBook.budget)) 원",
            todayVC: todayViewController
        )

        let headerSize = tripSummaryView.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        )
        tripSummaryView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerSize.height)

        tableView.tableHeaderView = tripSummaryView
        
        bindFormattedTotal()
    }
    
    private func bindFormattedTotal() {
        todayViewController.formattedTotalRelay
            .bind(to: tripSummaryView.progressView.expense) // ✅ `TopProgressView`에 값 전달
            .disposed(by: disposeBag)
    }
}

extension String {
    /// `yyyyMMdd` 형식의 문자열을 `yyyy.MM.dd` 형식으로 변환
    func formattedDate() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd" // 기존 형식 (예: 20250220)
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국 시간 기준
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd" // 변경할 형식
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        }
        return self // 변환 실패 시 원본 반환
    }
}

