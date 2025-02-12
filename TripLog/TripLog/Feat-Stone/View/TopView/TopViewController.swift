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
    
    /// ✅ 여행 요약 정보를 포함하는 상단 뷰
    private lazy var tripSummaryView = TripLogSummaryView(switcherView: switcherView)
    
    private let contentContainerView = UIView()
    
    private var balance: Int = 0

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
//        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        guard let cashBook = viewModel.sections.value.first?.items.first else { return }
        self.navigationItem.title = viewModel.sections.value.first?.items.first?.tripName ?? "여행"
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
    private func bindFormattedTotal() {
        todayViewController.formattedTotalRelay
            .subscribe(onNext: { [weak self] totalAmount in
                print("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                self?.tripSummaryView.progressView.expense.accept(totalAmount)
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
            $0.top.leading.trailing.equalToSuperview().inset(16)
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
