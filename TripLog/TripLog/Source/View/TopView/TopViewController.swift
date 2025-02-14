import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

final class TopViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    fileprivate let todayViewController: TodayViewController
    fileprivate let calendarViewController: CalendarViewController
    
    private lazy var switcherView: TripSwitcherView = {
        return TripSwitcherView(todayView: todayViewController.view, calendarView: calendarViewController.view)
    }()
    
    /// ✅ 여행 요약 정보를 포함하는 상단 뷰 (별도 파일로 분리됨)
    private lazy var tripSummaryView = TripLogSummaryView(switcherView: switcherView)
            
    private var cashBook: CashBookModel

    init(cashBook: CashBookModel) {
        self.cashBook = cashBook
        self.todayViewController = TodayViewController(cashBookID: cashBook.id)
        self.calendarViewController = CalendarViewController(cashBook: cashBook.id, balance: cashBook.budget)
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
        
        tripSummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        
        self.navigationItem.title = cashBook.tripName
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.SCDream(size: .title, weight: .bold)
        ]
        
        tripSummaryView.configure(
            subtitle: cashBook.note,
            date: "\(cashBook.departure.formattedDate()) - \(cashBook.homecoming.formattedDate())",
            budget: cashBook.budget,
            amount: getTotalAmount()
        )
    }
    
    private func getTotalAmount() -> Int {
        let data = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: self.cashBook.id)
        let totalExpense = data.reduce(0) { $0 + Int(round($1.caculatedAmount))}
        
        return totalExpense
    }

    /// ✅ 오늘 지출 업데이트 바인딩
    private func bindFormattedTotal() {
        todayViewController.rx.totalAmount
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                owner.tripSummaryView.progressView.expense.accept(totalAmount)
                owner.calendarViewController.reloadCalendarView()
            }
            .disposed(by: disposeBag)
        
        calendarViewController.rx.updateTotalAmount
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                owner.tripSummaryView.progressView.expense.accept(totalAmount)
                owner.todayViewController.updateTodayConsumption()
            }
            .disposed(by: disposeBag)
    }
}

// 사용하는 뷰컨트롤러에 추가를 해주셔야 popover기능을 아이폰에서 정상적으로 사용 가능합니다.
extension TopViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
