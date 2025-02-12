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
    private var calendarViewController: CalendarViewController
    
    private var balance: Int = 0
    
    private lazy var switcherView: TripSwitcherView = {
        return TripSwitcherView(todayView: todayViewController.view, calendarView: calendarViewController.view)
    }()
    
    /// ✅ 여행 요약 정보를 포함하는 상단 뷰
    private lazy var tripSummaryView = TripLogSummaryView(switcherView: switcherView)
    
    private lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = false
        $0.rowHeight = self.view.bounds.height
        $0.backgroundColor = UIColor.CustomColors.Background.detailBackground
    }
    
    init(cashBook: MockCashBookModel) {
        self.viewModel = TopViewModel(cashBook: cashBook)
        self.todayViewController = TodayViewController(cashBookID: cashBook.id)
        self.calendarViewController = CalendarViewController(cashBook: cashBook.id, balance: balance)
        super.init(nibName: nil, bundle: nil)
        bindBalance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupUI()
        setupTableView()
        bindFormattedTotal()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(tripSummaryView)
        
        tripSummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(tripSummaryView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        guard let cashBook = viewModel.sections.value.first?.items.first else { return }
        self.navigationItem.title = cashBook.tripName
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
        tripSummaryView.configure(
            subtitle: cashBook.note,
            date: "\(cashBook.departure.formattedDate()) - \(cashBook.homecoming.formattedDate())",
            budget: "\(NumberFormatter.formattedString(from: Double(cashBook.budget)))",
            todayVC: todayViewController
        )
    }
    
    private func setupTableView() {
        tableView.tableHeaderView = tripSummaryView
        
        let headerSize = tripSummaryView.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        )
        tripSummaryView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerSize.height)
    }
    
//    private func setupTripSummary() {
//        bindFormattedTotal()
//    }
    
    private func bindFormattedTotal() {
        todayViewController.formattedTotalRelay
            .bind(to: tripSummaryView.progressView.expense)
            .disposed(by: disposeBag)
    }
    
    private func bindBalance() {
        tripSummaryView.progressView.balanceRelay
            .subscribe(onNext: { [weak self] balance in
                guard let self = self else { return }
                self.balance = balance // ✅ balance 업데이트
                self.calendarViewController = CalendarViewController(cashBook: self.viewModel.cashBook.id, balance: balance)
            })
            .disposed(by: disposeBag)
        }
}

/// 🔹 여행 요약 정보를 표시하는 뷰 (타이틀, 날짜, 예산, 진행 상태, 버튼 포함)
final class TripLogSummaryView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let switcherView: TripSwitcherView
    
    /// 🔹 `titleDateView`, `progressView`, `buttonStackView`를 감싸는 컨테이너 뷰
    private let tripSummaryContainerView = UIView()
    
    private let titleDateView = TitleDateView()
    let progressView = TopProgressView()
    private let buttonStackView = TopCustomButtonStackView()
    
    /// ✅ `TripSwitcherView`를 인자로 받아 초기화
    init(switcherView: TripSwitcherView) {
        self.switcherView = switcherView
        super.init(frame: .zero)
        setupLayout()
        setupButtonActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// ✅ 여행 정보를 설정하는 메서드
    func configure(subtitle: String, date: String, budget: String, todayVC: TodayViewController) {
        titleDateView.configure(subtitle: subtitle, date: date)
        bindToProgressView(todayVC: todayVC, budget: budget)
    }
    
    /// ✅ ProgressView와 TodayViewController 연결
    private func bindToProgressView(todayVC: TodayViewController, budget: String) {
        progressView.setBudget(budget)
        
        todayVC.onTotalAmountUpdated = { [weak self] totalAmount in
            self?.progressView.expense.accept(totalAmount)
        }
    }
    
    private func setupLayout() {
        tripSummaryContainerView.backgroundColor = UIColor.CustomColors.Background.background
        addSubview(tripSummaryContainerView)
        addSubview(switcherView)
        
        /// ✅ tripSummaryContainerView 내부에 `titleDateView`, `progressView`, `buttonStackView` 추가
        [titleDateView, progressView, buttonStackView].forEach { tripSummaryContainerView.addSubview($0) }
        
        /// ✅ `tripSummaryContainerView` 레이아웃 설정
        tripSummaryContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonStackView.snp.bottom)
        }
        
        titleDateView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(8)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview()
        }
        
        switcherView.snp.makeConstraints {
            $0.top.equalTo(tripSummaryContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    /// ✅ 버튼 클릭 시 `TripSwitcherView`의 뷰 변경
    private func setupButtonActions() {
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.switcherView.showTodayView()
            },
            calendarAction: { [weak self] in
                self?.switcherView.showCalendarView()
            }
        )
    }
}
