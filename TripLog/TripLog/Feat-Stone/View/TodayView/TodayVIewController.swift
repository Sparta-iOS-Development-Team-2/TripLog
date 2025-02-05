import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import CoreData

class TodayViewController: UIViewController {
    
    var onExpenseUpdated: ((String) -> Void)?
    
    let viewModel: TodayViewModel  // ViewModel을 올바르게 선언
    private let disposeBag = DisposeBag()
    private let topStackView = UIStackView()

    private let headerTitleLabel = UILabel().then {
        $0.text = "지출 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
    }
    
    private let helpButton = UIButton(type: .system).then {
        $0.setTitle("?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let totalLabel = UILabel().then {
        $0.text = "오늘 사용 금액"
        $0.font = UIFont.SCDream(size: .body, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    
    private let totalAmountLabel = UILabel().then {
        $0.text = "0 원"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
    }
    
    private let tableView = UITableView().then {
        $0.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        $0.separatorStyle = .none
        $0.applyBackgroundColor()
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        $0.showsVerticalScrollIndicator = false
    }

    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        $0.tintColor = UIColor.Personal.normal
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }

    // CoreData 컨텍스트를 전달받아 ViewModel을 초기화
    init(context: NSManagedObjectContext) {
        self.viewModel = TodayViewModel(context: context)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyBackgroundColor()
        
        setupViews()
        setupConstraints()
        setupFloatingButton()
        
        bindViewModel()  // ViewModel 바인딩
    }

    private func bindViewModel() {
        // 테이블 뷰 바인딩 (CoreData에서 불러온 데이터 표시)
        viewModel.expenses
            .bind(to: tableView.rx.items(cellIdentifier: ExpenseCell.identifier, cellType: ExpenseCell.self)) { _, expense, cell in
                let originalAmount = Int(expense.amount) // Double → Int 변환
                let convertedAmount = Int(expense.amount * 1.4) // Double → Int 변환

                let exchangeRateString = "\(NumberFormatter.formattedString(from: convertedAmount)) 원" // 천 단위 변환 적용

                cell.configure(
                    date: "오늘",
                    title: expense.note,
                    category: expense.category,
                    amount: "$ \(NumberFormatter.formattedString(from: originalAmount))", // 천 단위 적용
                    exchangeRate: exchangeRateString
                )
            }
            .disposed(by: disposeBag)

        
        // 모달에서 데이터가 추가되면 테이블을 자동으로 리로드
        viewModel.expenses
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 총 금액 바인딩 (모든 exchangeRate 값의 합산)
        viewModel.expenses
            .map { expenses in
                let totalExchangeRate = expenses
                    .map { Int($0.amount * 1.4) } // 모든 amount * 1.4 변환 후 합산
                    .reduce(0, +)
                return "\(NumberFormatter.formattedString(from: totalExchangeRate)) 원" // 천 단위 변환 적용
            }
            .do(onNext: { [weak self] totalAmount in
                self?.onExpenseUpdated?(totalAmount) // TopProgressView 업데이트
            })
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)


        // 삭제 이벤트 바인딩
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.deleteExpense(at: indexPath.section)
            })
            .disposed(by: disposeBag)

        // ViewModel에서 모달 트리거 감지
        viewModel.showAddExpenseModal
            .subscribe(onNext: { [weak self] in
                self?.presentExpenseAddModal()
            })
            .disposed(by: disposeBag)
        // 테이블 뷰 셀 선택 이벤트 감지 및 모달 띄우기
        tableView.rx.modelSelected(MockMyCashBookModel.self)
            .subscribe(onNext: { [weak self] selectedExpense in
                guard let self = self else { return }
                
                ModalViewManager.showModal(on: self, state: .editConsumption(data: selectedExpense))
                    .subscribe(onNext: {
                        // 모달이 닫히면 데이터 다시 로드
                        self.viewModel.fetchExpenses()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    // Floating Button을 ViewModel을 통해 동작하도록 수정
    private func setupFloatingButton() {
        view.addSubview(floatingButton)

        floatingButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }

    @objc private func floatingButtonTapped() {
        viewModel.triggerAddExpenseModal() // ViewModel에서 모달을 띄우도록 변경
    }

    @objc private func presentExpenseAddModal() {
        ModalViewManager.showModal(on: self, state: .createNewConsumption)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                // 새로운 데이터를 불러와 테이블 뷰를 갱신
                self.viewModel.fetchExpenses()
            })
            .disposed(by: disposeBag)
    }

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

    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

/// 1,000 천 단위 표기
extension NumberFormatter {
    static func formattedString(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 🔹 천 단위 구분 적용
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}


@available(iOS 17.0, *)
#Preview("TodayViewController") {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let viewController = TodayViewController(context: context)
    return UINavigationController(rootViewController: viewController)
}
