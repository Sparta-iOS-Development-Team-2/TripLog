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
    let formattedTotalRelay = BehaviorRelay<String>(value: "0 원") // ✅ Rx로 관리

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

        filteredExpenses
            .map { expenses -> String in
                let totalExchangeRate = expenses.map { Int($0.amount * 1.4) }.reduce(0, +)
                let formattedTotal = "\(NumberFormatter.wonFormat(totalExchangeRate)) 원"
                print("🔹 formattedTotal 업데이트됨: \(formattedTotal)")
                return formattedTotal
            }
            .startWith("0 원") // ✅ 첫 화면 로딩 시 기본 값 설정
            .drive(formattedTotalRelay) // ✅ `formattedTotalRelay`에 값 전달
            .disposed(by: disposeBag)

        // ✅ `totalAmountLabel`에 바인딩하여 UI 반영
        formattedTotalRelay
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        filteredExpenses
            .drive(onNext: { [weak self] expenses in
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
                // TODO: 모달뷰 로직 추후 수정 요청(석준)
                return ModalViewManager.showModal(state: .editConsumption(data: selectedExpense, exchangeRate: [])).map { $0 }
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
        ModalViewManager.showModal(state: .createNewConsumption(data: .init(cashBookID: self.cashBookID, date: Date(), exchangeRate: [])))
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] data in
                guard let self = self,
                let cashBookData = data as? MockMyCashBookModel else { return }
                debugPrint("📌 모달뷰 닫힘 후 데이터 갱신 시작")
                
                CoreDataManager.shared.save(type: MyCashBookEntity.self, data: cashBookData)
                
                // ✅ fetchTrigger 실행하여 데이터 갱신 요청
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)

                // ✅ fetchTrigger 실행 후 1초 뒤 `expenses`를 다시 구독하여 값 확인
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.output.expenses
                        .drive(onNext: { fetchedExpenses in
                            print("📌 🔥 fetchTrigger 실행 후 expenses 업데이트됨: \(fetchedExpenses.count)개 항목")
                        })
                        .disposed(by: self.disposeBag)

                    // ✅ 테이블 뷰 강제 갱신 (UI 반영 확인용)
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }

    private func presentExpenseEditModal(data: MockMyCashBookModel) {
        ModalViewManager.showModal(state: .editConsumption(data: data, exchangeRate: []))
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] updatedData in
                guard let self = self,
                      let updatedExpense = updatedData as? MockMyCashBookModel else { return }
                debugPrint("📌 모달뷰 닫힘 후 수정된 데이터: \(updatedExpense)")

                // ✅ 기존 데이터를 CoreData에 업데이트 (entityID 추가)
                CoreDataManager.shared.update(
                    type: MyCashBookEntity.self,
                    entityID: updatedExpense.id, // ⚠️ 수정할 entity의 ID 전달
                    data: updatedExpense
                )

                // ✅ fetchTrigger 실행하여 데이터 갱신 요청
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)

                // ✅ fetchTrigger 실행 후 1초 뒤 `expenses`를 다시 구독하여 값 확인
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.output.expenses
                        .drive(onNext: { fetchedExpenses in
                            print("📌 🔥 fetchTrigger 실행 후 expenses 업데이트됨: \(fetchedExpenses.count)개 항목")
                        })
                        .disposed(by: self.disposeBag)

                    // ✅ 테이블 뷰 강제 갱신 (UI 반영 확인용)
                    self.tableView.reloadData()
                }
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
        
        // ✅ "삭제" 버튼을 위한 UIView 생성
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 108)) // ✅ 셀 높이와 맞춤
        deleteView.backgroundColor = UIColor.CustomColors.Background.detailBackground
        deleteView.layer.cornerRadius = 8

        // ✅ "삭제" 텍스트 버튼 추가
        let deleteLabel = UILabel()
        deleteLabel.text = "삭제"
        deleteLabel.textColor = .white
        deleteLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        deleteLabel.textAlignment = .center
        deleteLabel.textColor = .white

        deleteView.addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints {
            $0.center.equalToSuperview() // ✅ 정중앙 배치
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }

        // ✅ UIView를 UIImage로 변환하여 UIContextualAction에 적용
        let deleteImage = deleteView.asImage()

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completionHandler in
            guard let self = self else { return }

            let alertController = UIAlertController(
                title: "삭제 확인",
                message: "정말로 삭제하시겠습니까?",
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                completionHandler(false)
            }

            let confirmAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.viewModel.input.deleteExpenseTrigger.accept(indexPath.row)
                completionHandler(true)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true)
        }

        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

// ✅ UIView를 UIImage로 변환하는 확장 함수
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
