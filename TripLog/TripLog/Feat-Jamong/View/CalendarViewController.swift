//
//  CalendarViewController.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import Then
import SnapKit

/// 캘린더 화면을 관리하는 뷰컨트롤러
/// - 캘린더와 지출 목록을 스크롤 뷰로 표시
/// - FSCalendar를 사용한 날짜 선택 및 데이터 표시
/// - 다크모드 대응 및 그림자 최적화
final class CalendarViewController: UIViewController {
    // MARK: - UI Components
    /// 전체 컨텐츠를 스크롤 가능하게 하는 스크롤 뷰
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.contentInset.bottom = 100
    }
    
    /// 수직으로 뷰들을 쌓는 스택 뷰
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .equalSpacing
    }
    
    /// 캘린더와 헤더를 담는 컨테이너 뷰
    private lazy var calendarContainerView = UIView().then {
        $0.applyViewStyle()
    }
    
    /// 캘린더 뷰
    private lazy var calendarView = CalendarView().then {
        $0.calendar.delegate = self
        $0.calendar.dataSource = self
        $0.calendar.register(CalendarCustomCell.self, forCellReuseIdentifier: "CalendarCustomCell")
        $0.backgroundColor = .clear
    }
    
    /// 캘린더 상단의 커스텀 헤더 뷰
    private lazy var customHeaderView = CalendarCustomHeaderView(frame: .zero)
    
    /// 지출 목록을 표시하는 뷰
    private lazy var expenseListView = CalendarExpenseView().then {
        $0.applyViewStyle()
    }
    
    private let calendarViewModel : CalendarViewModel
    
    // MARK: - Initalization
    
    /// 가계부 ID 받아오기
    /// - Parameter cashBook: 가계부 ID
    init(cashBook: UUID, balance: Int) {
        self.calendarViewModel = CalendarViewModel(cashBookID: cashBook, balance: balance)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    /// 날짜별 지출 데이터를 저장하는 딕셔너리
    private let selectedDate = PublishRelay<Date>()
    fileprivate let updateTotalAmount = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        calendarView.calendar.select(Date())
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarContainerView.layer.shadowPath = calendarContainerView.shadowPath()
        expenseListView.layer.shadowPath = expenseListView.shadowPath()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        calendarContainerView.applyViewStyle()
        calendarContainerView.backgroundColor = UIColor.CustomColors.Background.background
        expenseListView.applyViewStyle()
        expenseListView.backgroundColor = UIColor.CustomColors.Background.background
    }
    
    func reloadCalendarView() {
        calendarViewModel.loadExpenseData()
    }
    
    // MARK: - Setup
    /// UI 컴포넌트들의 초기 설정을 담당하는 메서드
    private func setupUI() {
        expenseListView.tableView.delegate = self
        configureBaseView()
        configureCalendarContainer()
        configureScrollView()
    }
    
    /// 기본 뷰 설정
    private func configureBaseView() {
        view.backgroundColor = UIColor.CustomColors.Background.detailBackground
    }
    
    /// 스크롤 뷰 설정
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalToSuperview()
        }
        
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.bounds.width - 32)
        }
    }
    
    /// 캘린더 컨테이너 설정
    private func configureCalendarContainer() {
        [customHeaderView, calendarView].forEach { calendarContainerView.addSubview($0) }
        
        customHeaderView.snp.makeConstraints {
            $0.top.equalTo(calendarContainerView)
            $0.leading.trailing.equalTo(calendarContainerView)
            $0.height.equalTo(60)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(customHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(calendarContainerView)
            $0.bottom.equalTo(calendarContainerView)
        }
        
        contentStackView.addArrangedSubview(calendarContainerView)
        contentStackView.addArrangedSubview(expenseListView)
        calendarContainerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        expenseListView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func getTotalAmount() -> Int {
        let data = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: calendarViewModel.cashBookID)
        let totalExpense = data.reduce(0) { $0 + Int(round($1.caculatedAmount))}
        
        return totalExpense
    }
    
    // MARK: - Calendar Setup
    
    // CalendarViewModel 바인딩
    private func setupBindings() {
        let input: CalendarViewModel.Input = .init(
            previousButtonTapped: customHeaderView.rx.previousButtonTapped,
            nextButtonTapped: customHeaderView.rx.nextButtonTapped,
            addButtonTapped: expenseListView.rx.addButtondTapped,
            didSelected: selectedDate
            )
        
        let output = calendarViewModel.transform(input: input)
        
        output.updatedDate
            .asSignal(onErrorJustReturn: Date())
            .distinctUntilChanged()
            .withUnretained(self)
            .emit { owner, date in
                owner.customHeaderView.updateTitle(date: date)
                owner.calendarView.updatePageLoad(date: date)
            }
            .disposed(by: disposeBag)
        
        output.addButtonTapped
            .withUnretained(self)
            .flatMap { owner, date in
                
                let rates = CoreDataManager.shared.fetch(
                    type: CurrencyEntity.self,
                    predicate: Date.formattedDateString(from: date)
                )
                
                return ModalViewManager.showModal(state: .createNewConsumption(data: .init(cashBookID: owner.calendarViewModel.cashBookID, date: date, exchangeRate: rates)))
                    .compactMap {
                        $0 as? MockMyCashBookModel
                    }
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                CoreDataManager.shared.save(type: MyCashBookEntity.self, data: data)
                self?.calendarViewModel.loadExpenseData()
            }
            .disposed(by: disposeBag)
        
        // expense 지출내역 데이터 채우기
        output.expenses
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, data in
                owner.calendarView.calendar.reloadData()
                owner.expenseListView.configure(date: data.date, expenses: data.data, balance: data.balance)
                owner.updateTotalAmount.accept("\(owner.getTotalAmount())")
            }
            .disposed(by: disposeBag)
    }
}
                  

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    /// 각 날짜에 대한 캘린더 셀을 생성하고 구성한다.
    /// - Parameters:
    ///   - calendar: 현재 FSCalendar 인스턴스
    ///   - date: 셀에 표시될 날짜
    ///   - position: 날짜의 월 내 위치 (현재 월, 이전/다음 월 등)
    /// - Returns: 구성된 FSCalendarCell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCustomCell", for: date, at: position) as? CalendarCustomCell else {
            return FSCalendarCell()
        }
        
        configureCellDate(cell, for: date)
        configureCellExpense(cell, for: date)
        configureCellAppearance(cell, for: date, in: calendar)
        
        return cell
    }
    
    /// 셀의 날짜 레이블을 설정하는 메서드
    /// - Parameters:
    ///   - cell: 설정할 캘린더 커스텀 셀
    ///   - date: 표시할 날짜
    private func configureCellDate(_ cell: CalendarCustomCell, for date: Date) {
        let day = Calendar.current.component(.day, from: date)
        cell.titleLabel.text = "\(day)"
    }
    
    
    /// 셀의 지출금액 레이블을 설정하는 메서드
    /// - Parameters:
    ///   - cell: 설정할 캘린더 커스텀 셀
    ///   - date: 지출금액을 계산할 날짜
    private func configureCellExpense(_ cell: CalendarCustomCell, for date: Date) {
        let totalExpense = calendarViewModel.totalExpense(date: date)
        if totalExpense > 0 {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.usesGroupingSeparator = true
            
            let formattedAmount = numberFormatter.string(from: NSNumber(value: totalExpense)) ?? "0"
            cell.expenseLabel.text = formattedAmount
            cell.expenseLabel.isHidden = false
        } else {
            cell.expenseLabel.text = nil
            cell.expenseLabel.isHidden = true
        }
    }
    
    /// 셀의 전체적인 외관을 설정하는 메서드
    /// - Parameters:
    ///   - cell: 설정할 캘린더 커스텀 셀
    ///   - date: 셀에 표시될 날짜
    ///   - calendar: 현재 FSCalendar 인스턴스
    private func configureCellAppearance(_ cell: CalendarCustomCell, for date: Date, in calendar: FSCalendar) {
        if calendar.selectedDate == date {
            configureSelectedCell(cell)
        } else {
            configureUnselectedCell(cell, for: date)
        }
    }
    
    /// 선택된 셀의 스타일을 설정하는 메서드
    /// - Parameter cell: 스타일을 적용할 셀
    private func configureSelectedCell(_ cell: CalendarCustomCell) {
        cell.contentView.backgroundColor = UIColor.CustomColors.Accent.blue
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.textColor = .white
        cell.expenseLabel.textColor = .white
    }
    
    /// 선택되지 않은 셀의 스타일을 설정하는 메서드
    /// - Parameters:
    ///   - cell: 스타일을 적용할 셀
    ///   - date: 셀의 날짜
    private func configureUnselectedCell(_ cell: CalendarCustomCell, for date: Date) {
        let isToday = Calendar.current.isDateInToday(date)
        cell.titleLabel.textColor = isToday ? UIColor.CustomColors.Accent.blue : UIColor.CustomColors.Text.textPrimary
        cell.expenseLabel.textColor = .red
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.backgroundColor = .clear
    }
    
    /// 셀 선택되었을 때 호출되는 메서드
    /// - Parameters:
    ///   - calendar: 현재 FSCalendar 인스턴스
    ///   - date: 선택된 날짜
    ///   - monthPosition: 선택된 날짜의 월 내 위치
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate.accept(date)
    }
}

extension CalendarViewController: UITableViewDelegate {
    /// 스와이프로 삭제 기능 추가
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let expenses = self.calendarViewModel.expensesForDate(date: self.calendarViewModel.selectedDate)
            let expense = expenses[indexPath.row]
            
            let alert = AlertManager(
                title: "경고",
                message: "해당 지출내역을 삭제하시겠습니까?",
                cancelTitle: "취소",
                destructiveTitle: "삭제"
            ) {
                self.calendarViewModel.deleteExpense(id: expense.id)
            }
            
            alert.showAlert(on: self, .alert)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// 셀 선택 시 수정 모달 표시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expenses = calendarViewModel.expensesForDate(date: calendarViewModel.selectedDate)
        let expense = expenses[indexPath.row]
        let rates = CoreDataManager.shared.fetch(type: CurrencyEntity.self, predicate: Date.formattedDateString(from: expense.expenseDate))
        
        ModalViewManager.showModal(state: .editConsumption(data: expense, exchangeRate: rates))
            .compactMap { $0 as? MockMyCashBookModel }
            .subscribe(onNext: { [weak self] updatedExpense in
                self?.calendarViewModel.updateExpense(updatedExpense)
            })
            .disposed(by: disposeBag)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Reactive where Base: CalendarViewController {
    var updateTotalAmount: PublishRelay<String> {
        return base.updateTotalAmount
    }
}
