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
    private let calendarViewController: CalendarViewController
    
    private lazy var switcherView: TripSwitcherView = {
        return TripSwitcherView(todayView: todayViewController.view, calendarView: calendarViewController.view)
    }()
    
    /// ✅ 여행 요약 정보를 포함하는 상단 뷰 (별도 파일로 분리됨)
    private lazy var tripSummaryView = TripLogSummaryView(switcherView: switcherView)
    
    private let contentContainerView = UIView()
    
    private var balance: Int = 0
    
    private var cashBook: MockCashBookModel? {
        return viewModel.sections.value.first?.items.first
    }

    init(cashBook: MockCashBookModel) {
        self.viewModel = TopViewModel(cashBook: cashBook)
        self.todayViewController = TodayViewController(cashBookID: cashBook.id)
        self.calendarViewController = CalendarViewController(cashBook: cashBook.id, balance: balance)
        super.init(nibName: nil, bundle: nil)
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
        bindFormattedTotal()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(tripSummaryView)
        view.addSubview(contentContainerView)
        
        tripSummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(tripSummaryView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        contentContainerView.addSubview(switcherView)
        
        switcherView.snp.makeConstraints {
            $0.edges.equalToSuperview() // 컨테이너 뷰 크기와 동일하게 설정
        }
        
        guard let cashBook = cashBook else { return }
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

    /// ✅ 오늘 지출 업데이트 바인딩
    private func bindFormattedTotal() {
        todayViewController.formattedTotalRelay
            .subscribe(onNext: { [weak self] totalAmount in
                print("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                self?.tripSummaryView.progressView.expense.accept(totalAmount)
            })
            .disposed(by: disposeBag)
    }
}
