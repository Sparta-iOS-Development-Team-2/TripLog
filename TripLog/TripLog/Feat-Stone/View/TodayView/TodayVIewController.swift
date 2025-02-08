import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let viewModel: TodayViewModel
    
    // 🔹 상단 UI StackView
    private let topStackView = UIStackView()
    
    var onTotalAmountUpdated: ((String)->Void)?
    
    let totalExpense = BehaviorRelay<Int>(value: 0)

    // ✅ TripLogTopView에 반영할 총 지출 금액 Relay (클로저 방식)
    var onTotalExpenseUpdated: ((Int) -> Void)?

    // "지출 내역" 헤더 레이블
    private let headerTitleLabel = UILabel().then {
        $0.text = "지출 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
    }
        
    // 도움말 버튼
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
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = 108
        $0.clipsToBounds = true
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.allowsSelection = true
        $0.allowsMultipleSelection = false
    }
    
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Background.background
        $0.layer.cornerRadius = 32 // ((버튼 뷰 크기 - 버튼 패딩) / 2)
        $0.backgroundColor = UIColor.Personal.normal
        $0.applyFloatingButtonShadow()
        $0.applyFloatingButtonStroke()
    }

    
    private let cashBookID: UUID // ✅ 저장된 cashBookID

    init(cashBookID: UUID) {
        self.cashBookID = cashBookID
        self.viewModel = TodayViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 뷰가 로드될 때 실행
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.CustomColors.Background.detailBackground
        
        setupViews()
        setupConstraints()
        bindViewModel()
        
//        tableView.delegate = self
        
        // ✅ 데이터 가져오기 (viewDidLoad에서 실행)
        viewModel.input.fetchTrigger.accept(cashBookID)
        
        // ✅ Rx 방식으로 delegate 설정
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        updateExpense()
    }
    
    // 🔹 UI 요소 추가
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
        view.addSubview(floatingButton) // ✅ 추가
    }
    
    // 🔹 UI 레이아웃 설정
    private func setupConstraints() {
        topStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
            
        tableView.snp.makeConstraints {
            $0.top.equalTo(topStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func updateExpense() {

        let TotalExpense = totalExpense.value
        totalExpense.accept(TotalExpense)
    }
    
    private func bindViewModel() {
        
        // 🔹 동일한 `cashBookID`를 가진 항목만 표시하도록 필터링
        let filteredExpenses = viewModel.output.expenses
            .map { [weak self] expenses -> [MockMyCashBookModel] in
                guard let self = self else { return [] }
                return (expenses as? [MockMyCashBookModel])?.filter { $0.cashBookID == self.cashBookID } ?? []
            }

        // 🔹 **콘솔 출력 (디버깅용)**
        filteredExpenses
            .drive(onNext: { expenses in
                print("📌 expenses 데이터 확인:", expenses) // ✅ 콘솔에 데이터 출력
            })
            .disposed(by: disposeBag)

        // 🔹 테이블 뷰 바인딩 (필터링 적용)
        filteredExpenses
            .drive(tableView.rx.items(cellIdentifier: ExpenseCell.identifier, cellType: ExpenseCell.self)) { _, expense, cell in
                cell.configure(
                    date: "오늘",
                    title: expense.note,
                    category: expense.category,
                    amount: "$ \(NumberFormatter.formattedString(from: Int(expense.amount)))",
                    exchangeRate: "\(NumberFormatter.formattedString(from: Int(expense.amount * 1.4))) 원",
                    payment: expense.payment
                )
            }
            .disposed(by: disposeBag)

        // 🔹 **총 지출 금액을 `exchangeRate`의 합으로 반영 (필터링된 데이터만 적용)**
        filteredExpenses
            .map { expenses -> (Int, String) in
                let totalExchangeRate = expenses.map { Int($0.amount * 1.4) }.reduce(0, +)
                let formattedTotal = NumberFormatter.formattedString(from: totalExchangeRate)
                print("----\(formattedTotal)") // ✅ 디버깅용 출력
                return (totalExchangeRate, "\(formattedTotal) 원") // ✅ 튜플 반환
            }
            .drive(onNext: { [weak self] (totalExpense, totalAmount) in
                guard let self = self else { return }
                    
                self.totalAmountLabel.text = totalAmount // ✅ totalAmountLabel 업데이트
                self.onTotalExpenseUpdated?(totalExpense) // ✅ TopViewController로 전달
            })
            .disposed(by: disposeBag)


        filteredExpenses
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData() // ✅ 셀이 변경될 때 프로그레스 바 반영
            })
            .disposed(by: disposeBag)
        
        // ✅ 테이블 뷰 셀 선택 이벤트 감지 및 모달 띄우기
        tableView.rx.modelSelected(MockMyCashBookModel.self)
            .do(onNext: { selectedExpense in
                print("📌 선택된 셀 데이터 확인: \(selectedExpense)") // ✅ 선택 이벤트 로그 추가
            })
            .flatMapLatest { [weak self] selectedExpense -> Observable<Void> in
                guard let self = self else {
                    print("📌 self가 nil입니다.") // ✅ 메모리 해제 문제 확인
                    return .empty()
                }
                return ModalViewManager.showModal(on: self, state: .editConsumption(data: selectedExpense))
            }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("📌 수정 모달 닫힘 후 데이터 새로고침") // ✅ 모달 닫힌 후 이벤트 확인
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)
            })
            .disposed(by: disposeBag)
        
        // 🔹 모달 표시 바인딩 (RxSwift 적용)
        floatingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.presentExpenseAddModal()
            })
            .disposed(by: disposeBag)
        // ✅ `totalExpenseRelay` 값 변경될 때 `onTotalExpenseUpdated` 실행
        viewModel.totalExpenseRelay
            .subscribe(onNext: { [weak self] totalExpense in
                self?.onTotalExpenseUpdated?(totalExpense) // ✅ 값 변경 시 클로저 실행
                print("-----------\(totalExpense)")
            })
            .disposed(by: disposeBag)
    }
                           
    @objc private func presentExpenseAddModal() {
        ModalViewManager.showModal(on: self, state: .createNewConsumption(cashBookID: self.cashBookID, date: Date()))
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("📌 사용된 cashBookID: \(self.cashBookID)")
                print("📌 저장된 날짜: \(Date())")

                // ✅ 모달 닫힌 후 데이터 새로고침
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentExpenseEditModal(data: MockMyCashBookModel) {
        ModalViewManager.showModal(on: self, state: .editConsumption(data: data))
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("📌 수정된 내역: \(data)")
                
                // ✅ 모달 닫힌 후 데이터 새로고침
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)
            })
            .disposed(by: disposeBag)
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

    // 기본 삭제 기능 비활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false // 기본 삭제 버튼 비활성화
    }

    // 기본 삭제 기능을 완전히 비활성화
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 기본 삭제 기능 비활성화 (아무 동작도 하지 않음)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // ✅ 삭제 버튼 컨테이너 뷰 생성 (디자인 유지)
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
        deleteButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(30)
            $0.height.equalTo(30)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completionHandler in
            guard let self = self else { return }

            // ✅ 삭제 확인 알럿 띄우기
            let alertController = UIAlertController(
                title: "삭제 확인",
                message: "정말로 삭제하시겠습니까?",
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                completionHandler(false) // ✅ 취소 시 삭제되지 않음
            }

            let confirmAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                // ✅ Rx 방식으로 삭제 요청을 전달
                self.viewModel.input.deleteExpenseTrigger.accept(indexPath.row)
                completionHandler(true) // ✅ 삭제 완료
            }

            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)

            // ✅ 현재 뷰 컨트롤러에서 알럿 표시
            self.present(alertController, animated: true)
        }

        // ✅ 기존 디자인 적용 (배경 설정)
        deleteAction.backgroundColor = UIColor.CustomColors.Background.background
        // deleteAction.image = deleteView.asImage() // UIView를 UIImage로 변환하여 버튼 크기 반영 (필요 시 적용)

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false // ✅ 전체 스와이프 방지
        return configuration
    }
}
