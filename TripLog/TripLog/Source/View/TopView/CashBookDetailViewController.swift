import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CashBookDetailViewController: UIViewController {
        
    private var disposeBag = DisposeBag()
    
    private let expenditureViewController: ExpenditureViewController
    private let calendarViewController: CalendarViewController
    private let tripSummaryView: TripLogSummaryView
    
    // MARK: - Initializer
    
    init(cashBook: CashBookModel) {
        expenditureViewController = ExpenditureViewController(cashBookID: cashBook.id)
        calendarViewController = CalendarViewController(cashBook: cashBook)
        tripSummaryView = .init(cashBookData: cashBook)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = cashBook.tripName
        let currency = getTodayExchangeRate()
        expenditureViewController.updateCurrency(currency)
        calendarViewController.updateCurrency(currency)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        [expenditureViewController, calendarViewController].forEach {
            $0.view.snp.removeConstraints()
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        debugPrint("📌 deinit \(Self.self)")
    }
    
    // MARK: - VC LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        disposeBag = DisposeBag()
    }
}

// MARK: - CashBookDetailViewController Private Method

private extension CashBookDetailViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        setupChildVC()
        bind()
    }
    
    func configureSelf() {
        view.applyBackgroundColor()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
    }
    
    func setupLayout() {
        view.addSubview(tripSummaryView)
        
        tripSummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.25)
            $0.height.lessThanOrEqualTo(200)
        }
    }
    
    func setupChildVC() {
        [calendarViewController, expenditureViewController].forEach { vc in
            addChild(vc)
            view.addSubview(vc.view)
            
            vc.view.snp.makeConstraints {
                $0.top.equalTo(self.tripSummaryView.snp.bottom)
                $0.bottom.directionalHorizontalEdges.equalToSuperview()
            }
            
            vc.didMove(toParent: self)
        }
    }
    
    func changeCurrentView(_ isFirstButtonTapped: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.calendarViewController.view.alpha = isFirstButtonTapped ? 0 : 1
            self.expenditureViewController.view.alpha = isFirstButtonTapped ? 1 : 0
            self.tripSummaryView.changeButtonStyle(isFirstButtonTapped)
        }
    }
    
    /// 오늘의 환율을 반환하는 메소드
    /// - Returns: 금일 환율
    func getTodayExchangeRate() -> [CurrencyEntity] {
        let todayString = Date().formattedDateString()
        let exchangeRate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayString)
        
        return exchangeRate
    }
    
    func bind() {
        expenditureViewController.rx.totalAmount
            .distinctUntilChanged()
            .skip(until: expenditureViewController.rx.viewDidAppear)
            .take(until: expenditureViewController.rx.deallocated)
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 expenditureView 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                owner.tripSummaryView.updateProgress(totalAmount)
                owner.calendarViewController.reloadCalendarView()
            }
            .disposed(by: disposeBag)
        
        calendarViewController.rx.updateTotalAmount
            .distinctUntilChanged()
            .skip(until: calendarViewController.rx.viewDidAppear)
            .take(until: calendarViewController.rx.deallocated)
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 calendarView 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                owner.tripSummaryView.updateProgress(totalAmount)
                owner.expenditureViewController.updateTodayConsumption()
            }
            .disposed(by: disposeBag)
        
        tripSummaryView.rx.firstButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.changeCurrentView(true)
            }
            .disposed(by: disposeBag)
        
        tripSummaryView.rx.secondButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.changeCurrentView(false)
            }
            .disposed(by: disposeBag)
    }
}
