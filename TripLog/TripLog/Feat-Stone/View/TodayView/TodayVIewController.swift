import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TodayViewController: UIViewController {
    
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
        $0.textColor = UIColor(named: "textPrimary")
    }
        
    // 도움말 버튼
    // 도움말 버튼 (원형으로 만들기)
    private let helpButton = UIButton(type: .system).then {
        $0.setTitle("?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.applyBackgroundColor()
        $0.clipsToBounds = true
        $0.applyFloatingButtonShadow()
        $0.applyCornerRadius(12)
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
        $0.rowHeight = 124
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
        self.viewModel = TodayViewModel(cashBookID: cashBookID)
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
                
        // ✅ 데이터 가져오기 (viewDidLoad에서 실행)
        viewModel.input.fetchTrigger.accept(cashBookID)
        
        // ✅ Rx 방식으로 delegate 설정
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        updateExpense()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        floatingButton.layer.shadowPath = floatingButton.shadowPath()
        helpButton.layer.shadowPath = helpButton.shadowPath()
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
        
        helpButton.snp.makeConstraints {
            $0.width.height.equalTo(24) // 버튼 크기를 40x40으로 고정
        }
        
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
    }
    
    private func updateExpense() {

        let TotalExpense = totalExpense.value
        totalExpense.accept(TotalExpense)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            let emptyLabel = UILabel().then {
                $0.text = "지출 내역이 없습니다"
                $0.font = .SCDream(size: .body, weight: .medium)
                $0.textColor = UIColor.CustomColors.Text.textSecondary
                $0.textAlignment = .center
            }
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }

    private func bindViewModel() {
        
        // 🔹 동일한 `cashBookID`, 날짜를 가진 항목만 표시하도록 필터링
        let filteredExpenses = viewModel.output.expenses
            .map { [weak self] expenses -> [MockMyCashBookModel] in
                guard let self = self else { return [] }
                
                let today = Calendar.current.startOfDay(for: Date()) // 🔹 오늘 날짜 (시간 제거)
                
                return expenses.filter {
                    $0.cashBookID == self.cashBookID &&
                    Calendar.current.isDate($0.expenseDate, inSameDayAs: today) // 🔹 오늘 날짜와 같은 데이터만 필터링
                }
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
                    date: self.getTodayDate(),
                    title: expense.note,
                    category: expense.category,
                    amount: "\(expense.amount.formattedCurrency(currencyCode: expense.country))",
                    exchangeRate: "\(NumberFormatter.formattedString(from: expense.caculatedAmount.rounded())) 원",
                    payment: expense.payment
                )
            }
            .disposed(by: disposeBag)

        // 🔹 `cashBookID` 기준으로만 필터링 (총합 계산용)
        let totalExpensesByID = viewModel.output.expenses
            .map { [weak self] expenses -> [MockMyCashBookModel] in
                guard let self = self else { return [] }
                
                return expenses.filter { $0.cashBookID == self.cashBookID } // 🔹 날짜 필터링 제거
            }

        // 🔹 **필터링된 데이터에서 총합 계산**
        totalExpensesByID
            .map { expenses -> String in
                let totalExchangeRate = expenses.map { Int($0.caculatedAmount) }.reduce(0, +) // ✅ `cashBookID` 기반으로 총합 계산
                let formattedTotal = NumberFormatter.formattedString(from: Double(totalExchangeRate)) + " 원"
                print("🔹 formattedTotal 업데이트됨: \(formattedTotal)")
                
                return formattedTotal
            }
            .startWith("0 원") // ✅ 첫 화면 로딩 시 기본 값 설정
            .drive(formattedTotalRelay) // ✅ `formattedTotalRelay`에 값 전달
            .disposed(by: disposeBag)


        // ✅ `totalAmountLabel`에 바인딩하여 UI 반영
        filteredExpenses
            .map { expense -> String in
                let todayTotalExpense = Int(expense.reduce(0) { $0 + $1.caculatedAmount })
                return NumberFormatter.wonFormat(todayTotalExpense)
            }
            .asObservable()
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        filteredExpenses
            .drive(onNext: { [weak self] expenses in
                guard let self = self else { return }
                
                self.updateEmptyState(isEmpty: expenses.isEmpty)
                
                self.tableView.reloadData() // ✅ 셀이 변경될 때 프로그레스 바 반영
            })
            .disposed(by: disposeBag)
                
        tableView.rx.modelSelected(MockMyCashBookModel.self)
            .subscribe(onNext: { [weak self] selectedExpense in
                guard let self = self else { return }

                print("📌 선택된 셀 데이터 확인: \(selectedExpense)")

                // ✅ 선택된 데이터를 이용하여 편집 모달 띄우기
                self.presentExpenseEditModal(data: selectedExpense)
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
        
        helpButton.rx.tap
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                let recentRateDate = Date.caculateDate()
                PopoverManager.showPopover(on: owner,
                                           from: owner.helpButton,
                                           title: "현재의 환율은 \(recentRateDate) 환율입니다.",
                                           subTitle: "한국 수출입 은행에서 제공하는 가장 최근 환율정보입니다.",
                                           width: 170,
                                           height: 60,
                                           arrow: .down)
                
            }.disposed(by: disposeBag)
    }
                           
    @objc private func presentExpenseAddModal() {
        
        // 오늘 날짜를 "YYYYMMDD" 형식의 문자열로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let todayString = dateFormatter.string(from: Date())

        // CoreData에서 오늘 날짜에 해당하는 데이터 가져오기
        let exchangeRate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayString)

        
        ModalViewManager.showModal(state: .createNewConsumption(data: .init(cashBookID: self.cashBookID, date: Date(), exchangeRate: exchangeRate)))
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
                            print("ee\(exchangeRate)")
                        })
                        .disposed(by: self.disposeBag)

                    // ✅ 테이블 뷰 강제 갱신 (UI 반영 확인용)
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }

    private func presentExpenseEditModal(data: MockMyCashBookModel) {
        let todayDate = Date.formattedDateString(from: Date())
        let exchagedRate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayDate)
        
        ModalViewManager.showModal(state: .editConsumption(data: data, exchangeRate: exchagedRate))
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] updatedData in
                guard let self = self,
                      let updatedExpense = updatedData as? MockMyCashBookModel else { return }

                debugPrint("📌 모달뷰 닫힘 후 수정된 데이터: \(updatedExpense)")

                // ✅ CoreData에서 기존 데이터를 업데이트
                CoreDataManager.shared.update(type: MyCashBookEntity.self, entityID: updatedExpense.id, data: updatedExpense)

                // ✅ fetchTrigger 실행하여 데이터 갱신 요청
                self.viewModel.input.fetchTrigger.accept(self.cashBookID)

                // ✅ 데이터 갱신 후 UI 업데이트 (비동기 처리)
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
    
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"  // 날짜 포맷 설정
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일 적용 (필요시 변경 가능)
        return dateFormatter.string(from: Date()) // 현재 날짜 반환
    }
    
    func updateTodayConsumption() {
        viewModel.input.fetchTrigger.accept(cashBookID)
    }
}

// 🔹 천 단위 숫자 포맷 변환 (소수점 유지)
extension NumberFormatter {
    static func formattedString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        // ✅ 정수라면 소수점 제거, 소수점이 있으면 최대 2자리 표시
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0  // 정수일 때 소수점 제거
        } else {
            formatter.minimumFractionDigits = 2  // 소수점이 있을 때 최소 2자리
            formatter.maximumFractionDigits = 2  // 소수점 2자리까지 표시
        }

        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

extension TodayViewController: UITableViewDelegate {
    
    // 기본 삭제 기능을 완전히 비활성화
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 기본 삭제 기능 비활성화 (아무 동작도 하지 않음)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // ✅ "삭제" 버튼을 위한 UIView를 UIImage로 변환
        let deleteImage = createDeleteButtonImage()

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }

            let alert = AlertManager(title: "삭제 확인",
                                     message: "정말로 삭제하시겠습니까?",
                                     cancelTitle: "취소",
                                     destructiveTitle: "삭제")
            {
                self.viewModel.input.deleteExpenseTrigger.accept(indexPath.row)
                completionHandler(true)
            }
            
            alert.showAlert(on: self, .alert)
        }

        deleteAction.image = deleteImage // ✅ "삭제" 버튼을 이미지로 설정
        deleteAction.backgroundColor = UIColor.CustomColors.Background.detailBackground

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }

    /// ✅ "삭제" 버튼을 이미지로 생성하는 메서드 (cornerRadius 적용)
    private func createDeleteButtonImage() -> UIImage? {
        let size = CGSize(width: 70, height: 108) // ✅ 버튼 크기 설정
        let cornerRadius: CGFloat = 16 // ✅ 원하는 radius 값 설정
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // ✅ 둥근 모서리를 적용한 경로 생성
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            
            // ✅ 클리핑 적용 (둥근 모서리 적용을 위해 필요)
            context.cgContext.addPath(path.cgPath)
            context.cgContext.clip()
            
            // ✅ 배경 색 적용
            UIColor.red.setFill()
            context.fill(rect)

            // ✅ 텍스트 속성 설정
            let text = "삭제"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            // ✅ 텍스트 위치 조정 후 그리기
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
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

// 사용하는 뷰컨트롤러에 추가를 해주셔야 popover기능을 아이폰에서 정상적으로 사용 가능합니다.
extension TodayViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
