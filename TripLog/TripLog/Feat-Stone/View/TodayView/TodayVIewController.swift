import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import CoreData

class TodayViewController: UIViewController {
    
    // 총 지출 금액이 업데이트될 때 호출되는 클로저 (상위 뷰에서 활용 가능)
    var onExpenseUpdated: ((String) -> Void)?
    
    // ViewModel 인스턴스 (CoreData와 연동됨)
    let viewModel: TodayViewModel
    private let disposeBag = DisposeBag() // RxSwift 메모리 관리용 DisposeBag
    private let topStackView = UIStackView() // 상단 UI StackView

    // "지출 내역" 헤더 레이블
    private let headerTitleLabel = UILabel().then {
        $0.text = "지출 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
    }
    
    // 도움말 버튼 (현재 기능 없음, 확장 가능)
    private let helpButton = UIButton(type: .system).then {
        $0.setTitle("?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    // "오늘 사용 금액" 라벨
    private let totalLabel = UILabel().then {
        $0.text = "오늘 사용 금액"
        $0.font = UIFont.SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    
    // 총 금액 표시 라벨
    private let totalAmountLabel = UILabel().then {
        $0.text = "0 원"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
    }
    
    // 지출 내역을 표시할 테이블 뷰
    private let tableView = UITableView().then {
        $0.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        $0.separatorStyle = .none // 구분선 제거
        $0.applyBackgroundColor()
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = 108
        $0.clipsToBounds = true // 가로 스크롤 방지

        // 가로 스크롤 문제 해결
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    // 지출 추가 버튼 (Floating Button)
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = UIColor.Personal.normal
        $0.layer.cornerRadius = 32
        $0.applyFloatingButtonStyle()
    }

    // CoreData 컨텍스트를 받아 ViewModel을 초기화
    init(context: NSManagedObjectContext) {
        self.viewModel = TodayViewModel(context: context)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 뷰가 로드될 때 실행
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupViews()
        setupConstraints()
        setupFloatingButton()
        
        bindViewModel()
    }

    // ViewModel과 RxSwift를 사용하여 UI 데이터 바인딩
    private func bindViewModel() {
        // 테이블 뷰의 데이터 바인딩 (CoreData에서 가져온 데이터 표시)
        viewModel.expenses
            .bind(to: tableView.rx.items(cellIdentifier: ExpenseCell.identifier, cellType: ExpenseCell.self)) { _, expense, cell in
                let originalAmount = Int(expense.amount)
                let convertedAmount = Int(expense.amount * 1.4)

                let exchangeRateString = "\(NumberFormatter.formattedString(from: convertedAmount)) 원"

                cell.configure(
                    date: "오늘",
                    title: expense.note,
                    category: expense.category,
                    amount: "$ \(NumberFormatter.formattedString(from: originalAmount))",
                    exchangeRate: exchangeRateString
                )
            }
            .disposed(by: disposeBag)

        // 데이터 변경 감지 후 테이블 뷰 리로드
        viewModel.expenses
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 총 금액 바인딩 (모든 exchangeRate 값을 합산하여 표시)
        viewModel.expenses
            .map { expenses in
                let totalExchangeRate = expenses
                    .map { Int($0.amount * 1.4) }
                    .reduce(0, +)
                return "\(NumberFormatter.formattedString(from: totalExchangeRate)) 원"
            }
            .do(onNext: { [weak self] totalAmount in
                self?.onExpenseUpdated?(totalAmount)
            })
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)

        // 항목 삭제 이벤트 처리
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.deleteExpense(at: indexPath.section)
            })
            .disposed(by: disposeBag)

        // 모달 표시 트리거 감지 (새로운 지출 추가)
        viewModel.showAddExpenseModal
            .subscribe(onNext: { [weak self] in
                self?.presentExpenseAddModal()
            })
            .disposed(by: disposeBag)

        // 테이블 셀 선택 시 수정 모달 표시
        tableView.rx.modelSelected(MockMyCashBookModel.self)
            .subscribe(onNext: { [weak self] selectedExpense in
                guard let self = self else { return }
                
                ModalViewManager.showModal(on: self, state: .editConsumption(data: selectedExpense))
                    .subscribe(onNext: {
                        self.viewModel.fetchExpenses()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    // Floating Button 설정
    private func setupFloatingButton() {
        view.addSubview(floatingButton)

        floatingButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }

    // Floating Button 클릭 시 동작
    @objc private func floatingButtonTapped() {
        viewModel.triggerAddExpenseModal()
    }

    // 지출 추가 모달 표시
    @objc private func presentExpenseAddModal() {
        // TODO: 가계부ID를 받아오고 날짜를 지정하는 로직 추가 요청(석준)
        ModalViewManager.showModal(on: self, state: .createNewConsumption(cashBookID: UUID(), date: Date()))
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.fetchExpenses()
            })
            .disposed(by: disposeBag)
    }

    // UI 요소 설정
    private func setupViews() {
        let headerStackView = UIStackView(arrangedSubviews: [headerTitleLabel, helpButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        
        let totalStackView = UIStackView(arrangedSubviews: [totalLabel, totalAmountLabel]).then {
            $0.axis = .vertical
            $0.alignment = .trailing
            $0.spacing = 4
        }
        
        topStackView.addArrangedSubview(headerStackView)
        topStackView.addArrangedSubview(totalStackView)
        topStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        
        view.addSubview(topStackView)
        view.addSubview(tableView)
    }

    // UI 레이아웃 설정
    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// 천 단위 숫자 포맷 변환
extension NumberFormatter {
    static func formattedString(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}


@available(iOS 17.0, *)
#Preview("TodayViewController") {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let viewController = TodayViewController(context: context)
    return UINavigationController(rootViewController: viewController)
}
