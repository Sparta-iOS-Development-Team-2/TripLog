import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import CoreData

class TodayViewController: UIViewController {
    
    // 🔹 cashBookID를 저장하여 특정 가계부 데이터만 필터링
    private let cashBookID: UUID
    
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

    // 🔹 init에서 cashBookID를 받아 저장
    init(context: NSManagedObjectContext, cashBookID: UUID) {
        self.cashBookID = cashBookID
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
        
        // ✅ 특정 cashBookID를 가진 데이터만 가져오도록 수정
        viewModel.fetchExpenses(for: cashBookID)
    }

    // ViewModel과 RxSwift를 사용하여 UI 데이터 바인딩
    private func bindViewModel() {
        // 🔹 특정 cashBookID를 가진 지출 내역만 표시하도록 필터링
        viewModel.expenses
            .map { expenses in
                expenses.filter { $0.cashBookID == self.cashBookID }
            }
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

        // 🔹 특정 cashBookID를 가진 데이터만 합산하여 총 금액 표시
        viewModel.expenses
            .map { expenses in
                let totalExchangeRate = expenses
                    .filter { $0.cashBookID == self.cashBookID }
                    .map { Int($0.amount * 1.4) }
                    .reduce(0, +)
                return "\(NumberFormatter.formattedString(from: totalExchangeRate)) 원"
            }
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
                        self.viewModel.fetchExpenses(for: self.cashBookID) // ✅ self 추가
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
        // ✅ TopViewController에서 받은 cashBookID를 사용하도록 수정
        ModalViewManager.showModal(on: self, state: .createNewConsumption(cashBookID: self.cashBookID, date: Date()))
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("📌 사용된 cashBookID: \(self.cashBookID)") // ✅ 제대로 전달되는지 확인
                print("📌 저장된 날짜: \(Date())")
                self.viewModel.fetchExpenses(for: self.cashBookID)
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

extension TodayViewController: UITableViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
    }

    // 기본 삭제 기능 비활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false // 기본 삭제 버튼 비활성화
    }

    // 기본 삭제 기능을 완전히 비활성화
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 기본 삭제 기능 비활성화 (아무 동작도 하지 않음)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제 버튼 컨테이너 뷰 생성
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 40)).then {
            $0.backgroundColor = .red
            $0.layer.cornerRadius = 8
        }

        let deleteButton = UIButton(type: .system).then {
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        }

        deleteView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(50) // 버튼의 좌우 크기 조절
            make.height.equalTo(30) // 버튼의 높이 조절
        }

        let customDeleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.viewModel.deleteExpense(at: indexPath.row)
            completionHandler(true)
        }

        // 기본 배경 제거 후, 커스텀 뷰 적용
        customDeleteAction.backgroundColor = UIColor.CustomColors.Background.background
       // customDeleteAction.image = deleteView.asImage() // UIView를 UIImage로 변환하여 버튼 크기 반영

        let configuration = UISwipeActionsConfiguration(actions: [customDeleteAction])
        configuration.performsFirstActionWithFullSwipe = false // 전체 스와이프 방지

        return configuration
    }

}


@available(iOS 17.0, *)
#Preview("TodayViewController") {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // 🔹 샘플 가계부 ID 생성 (테스트용)
    let sampleCashBookID = UUID()

    let viewController = TodayViewController(context: context, cashBookID: sampleCashBookID)

    return UINavigationController(rootViewController: viewController)
}
