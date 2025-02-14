import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TodayViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<UUID>()
    private let deleteExpenseTrigger = PublishRelay<Int>()
    fileprivate let totalAmountRelay = PublishRelay<Int>()
    
    private let viewModel: TodayViewModel
    private let cashBookID: UUID // ✅ 저장된 cashBookID
    
    // 🔹 상단 UI StackView
    private let topStackView = UIStackView()
    
    // "지출 내역" 헤더 레이블
    private let headerTitleLabel = UILabel().then {
        $0.text = "지출 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
        $0.textColor = UIColor(named: "textPrimary")
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
        
        // ✅ 데이터 가져오기 (viewDidLoad에서 실행)
        fetchTrigger.accept(cashBookID)
        
        // ✅ Rx 방식으로 delegate 설정
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        floatingButton.layer.shadowPath = floatingButton.shadowPath()
    }
    
    func updateTodayConsumption() {
        fetchTrigger.accept(cashBookID)
    }
}

private extension TodayViewController {
    // 🔹 UI 요소 추가
    private func setupViews() {
        let headerStackView = UIStackView(arrangedSubviews: [headerTitleLabel]).then {
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
    func setupConstraints() {
        
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
    
    func updateEmptyState(isEmpty: Bool) {
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
    
    func bindViewModel() {
        
        let input: TodayViewModel.Input = .init(fetchTrigger: fetchTrigger,
                                                deleteExpenseTrigger: deleteExpenseTrigger
        )
        
        let output = viewModel.transform(input: input)
        
         output.expenses
            .asDriver(onErrorDriveWith: .empty())
            .drive(tableView.rx.items(cellIdentifier: ExpenseCell.identifier, cellType: ExpenseCell.self)) { [weak self] _, expense, cell in
                guard let self else { return }
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
        
        // ✅ `totalAmountLabel`에 바인딩하여 UI 반영
        output.expenses
            .map { expense -> String in
                let todayTotalExpense = Int(expense.reduce(0) { $0 + $1.caculatedAmount.rounded() })
                return NumberFormatter.wonFormat(todayTotalExpense)
            }
            .asObservable()
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        output.expenses
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, expenses in
                owner.updateEmptyState(isEmpty: expenses.isEmpty)
            }
            .disposed(by: disposeBag)
        
        output.deleteExpenseTrigger
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.fetchTrigger.accept(owner.cashBookID)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(MyCashBookModel.self)
            .withUnretained(self)
            .flatMap { owner, data in
                let exchangeRate = owner.getTodayExchangeRate()
                return ModalViewManager.showModal(state: .editConsumption(data: data, exchangeRate: exchangeRate))
                    .compactMap { $0 as? MyCashBookModel }
            }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                CoreDataManager.shared.update(type: MyCashBookEntity.self, entityID: data.id, data: data)
                owner.fetchTrigger.accept(owner.cashBookID)
                owner.totalAmountRelay.accept(owner.getTotalAmount())
            }.disposed(by: disposeBag)
        
        
        // 🔹 모달 표시 바인딩 (RxSwift 적용)
        floatingButton.rx.tap
            .withUnretained(self)
            .flatMap { owner, _ in
                let exchangeRate = owner.getTodayExchangeRate()
                return ModalViewManager.showModal(state: .createNewConsumption(data: .init(cashBookID: owner.cashBookID, date: Date(), exchangeRate: exchangeRate)))
                    .compactMap { $0 as? MyCashBookModel }
            }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, data in
                CoreDataManager.shared.save(type: MyCashBookEntity.self, data: data)
                owner.fetchTrigger.accept(owner.cashBookID)
                owner.totalAmountRelay.accept(owner.getTotalAmount())
            }.disposed(by: disposeBag)

    }
    
    func getTodayExchangeRate() -> [CurrencyEntity] {
        let todayString = Date.formattedDateString(from: Date())
        let exchangeRate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayString)
        
        return exchangeRate
    }
    
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"  // 날짜 포맷 설정
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일 적용 (필요시 변경 가능)
        return dateFormatter.string(from: Date()) // 현재 날짜 반환
    }
    
    func getTotalAmount() -> Int {
        let data = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: self.cashBookID)
        let totalExpense = data.reduce(0) { $0 + Int(round($1.caculatedAmount))}
        
        return totalExpense
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
                self.deleteExpenseTrigger.accept(indexPath.row)
                self.totalAmountRelay.accept(self.getTotalAmount())
                completionHandler(true)
            }
            
            alert.showAlert(.alert)
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

extension Reactive where Base: TodayViewController {
    var totalAmount: PublishRelay<Int> {
        base.totalAmountRelay
    }
}
