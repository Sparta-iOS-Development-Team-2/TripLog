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
        calendarViewController = CalendarViewController(cashBook: cashBook.id, balance: cashBook.budget)
        tripSummaryView = .init(cashBookData: cashBook)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = cashBook.tripName
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        [calendarViewController, expenditureViewController].forEach { vc in
            vc.removeFromParent()
            vc.view.removeFromSuperview()
            vc.view.snp.removeConstraints()
        }
        debugPrint("deinit", Self.self)
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
    
    func bind() {
        expenditureViewController.rx.totalAmount
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
                owner.tripSummaryView.updateProgress(totalAmount)
                owner.calendarViewController.reloadCalendarView()
            }
            .disposed(by: disposeBag)
        
        calendarViewController.rx.updateTotalAmount
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, totalAmount in
                debugPrint("🔹 지출 업데이트: \(totalAmount)") // ✅ 디버깅 출력
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

// 사용하는 뷰컨트롤러에 추가를 해주셔야 popover기능을 아이폰에서 정상적으로 사용 가능합니다.
extension CashBookDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
