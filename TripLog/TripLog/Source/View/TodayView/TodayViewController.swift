import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

final class TodayViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<UUID>()
    private let deleteExpenseTrigger = PublishRelay<IndexPath>()
    fileprivate let totalAmountRelay = PublishRelay<Int>()
    
    private let filterTapRelay = PublishRelay<Void>()
    
    // MARK: - Properties
    
    private let viewModel: TodayViewModel
    private let cashBookID: UUID // ✅ 저장된 cashBookID
    
    // MARK: - UI Components
    
    // 🔹 상단 UI StackView
    private let topStackView = UIStackView()
    
    // "지출 내역" 헤더 레이블
    private let headerTitleLabel = UILabel().then {
        $0.text = "전체 내역"
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
        $0.textColor = UIColor(named: "textPrimary")
    }
        
    // 도움말 버튼 (원형으로 만들기)
    private let helpButton = UIButton(type: .system).then {
        $0.setTitle("?", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.applyBackgroundColor()
        $0.clipsToBounds = true
        $0.applyFloatingButtonShadow()
        $0.applyCornerRadius(12)
    }

    // "필터" 라벨
    private let filterLabel = UILabel().then {
        $0.text = "필터"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    // 필터 이미지
    private let filterIcon = UIImageView().then {
        $0.image = UIImage(named: "filterIcon")?.withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { $0.size.equalTo(16) } // 아이콘 크기 조정
        $0.tintColor = .red
    }
    
    private let filterStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .trailing
        $0.spacing = 4
    }
    
    
    // 지출 내역을 표시할 테이블 뷰
    private let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = 96
        $0.clipsToBounds = true
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.allowsSelection = true
        $0.allowsMultipleSelection = false
        $0.sectionFooterHeight = 0 // 푸터 삭제
    }
    
    private let floatingButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Background.background
        $0.layer.cornerRadius = 32 // ((버튼 뷰 크기 - 버튼 패딩) / 2)
        $0.backgroundColor = UIColor.Personal.normal
        $0.applyFloatingButtonShadow()
        $0.applyFloatingButtonStroke()
    }
    
    // ✅ RxDataSources 사용을 위한 데이터소스 정의
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<TodaySectionModel>(
        configureCell: { _, tableView, indexPath, expense in
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCell.identifier, for: indexPath) as! ExpenseCell
            cell.configure(
                title: expense.note,
                category: expense.category,
                amount: "\(expense.amount.formattedCurrency(currencyCode: expense.country))",
                exchangeRate: "\(NumberFormatter.formattedString(from: expense.caculatedAmount.rounded())) 원",
                payment: expense.payment
            )
            return cell
        },
        titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].date // ✅ 섹션 헤더로 날짜 표시
        }
    )
    
    // MARK: - Initializer
    
    init(cashBookID: UUID) {
        self.cashBookID = cashBookID
        self.viewModel = TodayViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController LifeCycle
    
    // 뷰가 로드될 때 실행
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        floatingButton.layer.shadowPath = floatingButton.shadowPath()
        helpButton.layer.shadowPath = helpButton.shadowPath()
    }
    
    func updateTodayConsumption() {
        fetchTrigger.accept(cashBookID)
    }
}

// MARK: - Private Method

private extension TodayViewController {
    
    func setupUI() {
        view.backgroundColor = UIColor.CustomColors.Background.detailBackground
        
        setupViews()
        setupConstraints()
        bind()
        
        // ✅ 데이터 가져오기 (viewDidLoad에서 실행)
        fetchTrigger.accept(cashBookID)
    }
    
    // 🔹 UI 요소 추가
    func setupViews() {
        let headerStackView = UIStackView(arrangedSubviews: [headerTitleLabel, helpButton]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        
        filterStackView.addArrangedSubview(filterLabel)
        filterStackView.addArrangedSubview(filterIcon)
        
        topStackView.addArrangedSubview(headerStackView)
        topStackView.addArrangedSubview(filterStackView)
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
        
        // 스크롤을 최대로 했을 때 floatingButton 높이만큼 추가 여백 설정
        tableView.contentInset.bottom = 80
    }
    
    /// 지출 목록이 비었을 경우 emptyLabel의 hidden 속성을 변환하는 메소드
    /// - Parameter isEmpty: 지출 목록이 비어있는지에 대한 여부
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
            tableView.backgroundView?.removeFromSuperview()
            tableView.backgroundView = nil
        }
    }
    
    // Rx 바인딩 메소드
    func bind() {
        
        let input: TodayViewModel.Input = .init(fetchTrigger: fetchTrigger,
                                                deleteExpenseTrigger: deleteExpenseTrigger)
        
        let output = viewModel.transform(input: input)
        
        let tapGesture = UITapGestureRecognizer()
        filterStackView.addGestureRecognizer(tapGesture)
        filterStackView.isUserInteractionEnabled = true
        
        tapGesture.rx.event
            .map { _ in }
            .bind(to: filterTapRelay)
            .disposed(by: disposeBag)
        // 필터 이벤트
        filterTapRelay
            .subscribe (onNext:{
                print("필터 활성화")
            })
            .disposed(by: disposeBag)
        
        
        output.expenses
            .asDriver(onErrorDriveWith: .empty())
            .drive(tableView.rx.items(dataSource: dataSource))
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
        
        // ✅ `modelSelected` 수정: SectionModel을 고려하여 데이터 선택
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
            }
            .disposed(by: disposeBag)
        
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
        
        helpButton.rx.tap
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                let recentRateDate = Date.caculateDate()
                PopoverManager.showPopover(from: owner.helpButton,
                                           title: "현재의 환율은 \(recentRateDate) 환율입니다.",
                                           subTitle: "한국 수출입 은행에서 제공하는 가장 최근 환율정보입니다.",
                                           width: 170,
                                           height: 60,
                                           arrow: .down)
                
            }.disposed(by: disposeBag)
        
        
        // ✅ Rx 방식으로 delegate 설정
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    /// 오늘의 환율을 반환하는 메소드
    /// - Returns: 금일 환율
    func getTodayExchangeRate() -> [CurrencyEntity] {
        let todayString = Date.formattedDateString(from: Date())
        let exchangeRate = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: todayString)
        
        return exchangeRate
    }
    
    /// 오늘 날짜의 포맷을 변경하여 반환하는 메소드
    /// - Returns: "yyyy.MM.dd" 형식의 금일 날짜
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"  // 날짜 포맷 설정
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일 적용 (필요시 변경 가능)
        return dateFormatter.string(from: Date()) // 현재 날짜 반환
    }
    
    /// 현재 가계부의 총 지출 합계를 가져오는 메소드
    /// - Returns: 현재 가계부의 총 지출 합계
    func getTotalAmount() -> Int {
        let data = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: self.cashBookID)
        let totalExpense = data.reduce(0) { $0 + Int(round($1.caculatedAmount))}
        
        return totalExpense
    }
    
}

// MARK: - TableView Delegate Method

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
                self.deleteExpenseTrigger.accept(indexPath)
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
        let size = CGSize(width: 70, height: 90) // ✅ 버튼 크기 설정
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
    
    // 날짜 구분선 커스텀 UI
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < dataSource.sectionModels.count else { return nil }
        
        let sectionData = dataSource.sectionModels[section]
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // ✅ 배경을 투명하게 설정
        
        let label = UILabel().then {
            $0.text = sectionData.date.formattedDate()
            $0.textColor = .darkGray
            $0.font = UIFont.SCDream(size: .caption, weight: .medium)
        }
        
        let separatorView = UIView().then {
            $0.backgroundColor = .lightGray  // ✅ 구분선 색상
        }

        headerView.addSubview(label)
        headerView.addSubview(separatorView)

        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
        }

        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(8)  // ✅ Label 오른쪽에 위치
            make.trailing.equalToSuperview().inset(8)  // ✅ 오른쪽 마진 추가
            make.centerY.equalTo(label.snp.centerY)  // ✅ Label과 나란히 정렬
            make.height.equalTo(1)  // ✅ 실선을 얇게 설정
        }
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22 // ✅ 섹션 헤더 높이 설정
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: TodayViewController {
    /// 총 지출 합계를 이벤트로 방출하는 옵저버블
    var totalAmount: PublishRelay<Int> {
        base.totalAmountRelay
    }
}

