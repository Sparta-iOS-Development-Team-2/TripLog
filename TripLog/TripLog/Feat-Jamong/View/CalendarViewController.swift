//
//  CalendarViewController.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//

import UIKit
import RxSwift
import Then
import SnapKit
import FSCalendar

/// 캘린더 화면을 관리하는 뷰컨트롤러
/// - 캘린더와 지출 목록을 스크롤 뷰로 표시
/// - FSCalendar를 사용한 날짜 선택 및 데이터 표시
/// - 다크모드 대응 및 그림자 최적화
final class CalendarViewController: UIViewController {
    // MARK: - UI Components
    /// 전체 컨텐츠를 스크롤 가능하게 하는 스크롤 뷰
    private lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
    }
    
    /// 수직으로 뷰들을 쌓는 스택 뷰
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    /// 캘린더와 헤더를 담는 컨테이너 뷰
    private lazy var calendarContainerView = UIView().then {
        $0.applyViewStyle()
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
    
    /// 캘린더 뷰
    private lazy var calendarView = CalendarView().then {
        $0.calendar.delegate = self
        $0.calendar.dataSource = self
        $0.calendar.register(CalendarCustomCell.self, forCellReuseIdentifier: "CalendarCustomCell")
        $0.backgroundColor = .clear
    }
    
    /// 캘린더 상단의 커스텀 헤더 뷰
    private lazy var customHeaderView = CalendarCustomHeaderView(frame: .zero).then {
        $0.calendar = calendarView.calendar
        $0.backgroundColor = .clear
    }
    
    /// 지출 목록을 표시하는 뷰
    private lazy var expenseListView = CalendarExpenseView().then {
        $0.applyViewStyle()
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: - Properties
    /// 날짜별 지출 데이터를 저장하는 딕셔너리
    private var fakeTripExpenses: [Date: Double] = [:]
    private let disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
        generateFakeExpenseData()
        // 오늘 날짜 선택
        calendarView.calendar.select(Date())
        
        // 테스트용 ExpenseListView
        let testExpenses = [
            ExpenseItem(
                title: "스시 오마카세",
                foreignAmount: 15000.0,
                currencyType: .jpy,
                category: "식비",
                paymentMethod: "현금",
                wonAmount: 140044.0
            ),
            ExpenseItem(
                title: "라멘",
                foreignAmount: 1200.0,
                currencyType: .jpy,
                category: "식비",
                paymentMethod: "카드",
                wonAmount: 11203.0
            )
        ]
        
        // ExpenseListView 설정
        expenseListView.configure(
            date: Date(),
            expenses: testExpenses,
            balance: 560176
        )
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
    
    // MARK: - Setup
    /// UI 컴포넌트들의 초기 설정을 담당하는 메서드
    private func setupUI() {
        configureBaseView()
        configureScrollView()
        configureCalendarContainer()
        configureExpenseListView()
    }
    
    /// 기본 뷰 설정
    private func configureBaseView() {
        view.backgroundColor = UIColor.CustomColors.Background.background
    }
    
    /// 스크롤 뷰 설정
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
    }
    
    /// 캘린더 컨테이너 설정
    private func configureCalendarContainer() {
        contentStackView.addArrangedSubview(calendarContainerView)
        calendarContainerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().offset(16)
        }
        
        [customHeaderView, calendarView].forEach { calendarContainerView.addSubview($0) }
        
        customHeaderView.snp.makeConstraints {
            $0.top.equalTo(calendarContainerView.layoutMarginsGuide)
            $0.leading.trailing.equalTo(calendarContainerView.layoutMarginsGuide)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(customHeaderView.snp.bottom)
            $0.leading.trailing.equalTo(calendarContainerView.layoutMarginsGuide)
            $0.bottom.equalTo(calendarContainerView.layoutMarginsGuide)
            $0.height.equalTo(calendarView.snp.width)
        }
    }
    
    /// 지출 목록 뷰 설정
    private func configureExpenseListView() {
        contentStackView.addArrangedSubview(expenseListView)
        expenseListView.snp.makeConstraints {
            $0.height.equalTo(300)
        }
    }
    
    // MARK: - Calendar Setup
    /// 캘린더 초기 설정
    private func setupCalendar() {
        customHeaderView.updateTitle(date: calendarView.calendar.currentPage)
    }
    
    /// 지정된 날짜로 캘린더 페이지 변경
    /// - Parameter date: 이동할 날짜
    func changeMonth(to date: Date) {
        calendarView.calendar.setCurrentPage(date, animated: true)
    }
    
    // MARK: - Data Generation
    /// 테스트용 가짜 지출 데이터 생성
    private func generateFakeExpenseData() {
        let calendar = Calendar.current
        let currentDate = Date()
        var dateComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        for day in 1...31 {
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents) {
                if Bool.random() {
                    fakeTripExpenses[date] = Double.random(in: 1000...100000)
                }
            }
        }
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    /// 캘린더의 현재 페이지가 변경되었을 때 호출
    /// - Parameter calendar: 변경된 캘린더 객체
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        customHeaderView.updateTitle(date: calendar.currentPage)
    }
    
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
    
    private func configureCellDate(_ cell: CalendarCustomCell, for date: Date) {
        let day = Calendar.current.component(.day, from: date)
        cell.titleLabel.text = "\(day)"
    }
    
    private func configureCellExpense(_ cell: CalendarCustomCell, for date: Date) {
        if let expense = fakeTripExpenses[date] {
            cell.expenseLabel.text = (Int(expense).formatted())
            cell.expenseLabel.isHidden = false
        } else {
            cell.expenseLabel.text = nil
            cell.expenseLabel.isHidden = true
        }
    }
    
    private func configureCellAppearance(_ cell: CalendarCustomCell, for date: Date, in calendar: FSCalendar) {
        if calendar.selectedDate == date {
            configureSelectedCell(cell)
        } else {
            configureUnselectedCell(cell, for: date)
        }
    }
    
    private func configureSelectedCell(_ cell: CalendarCustomCell) {
        cell.contentView.backgroundColor = .systemBlue
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.textColor = .white
        cell.expenseLabel.textColor = .white
    }
    
    private func configureUnselectedCell(_ cell: CalendarCustomCell, for date: Date) {
        let isToday = Calendar.current.isDateInToday(date)
        
        cell.titleLabel.textColor = isToday ? .systemBlue : UIColor.CustomColors.Text.textPrimary
        cell.expenseLabel.textColor = .red
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.backgroundColor = .clear
    }
    
    /// 날짜가 선택되었을 때 호출되는 메서드 (데이터 확인용)
    /// - Parameters:
    ///   - calendar: 현재 FSCalendar 인스턴스
    ///   - date: 선택된 날짜
    ///   - monthPosition: 선택된 날짜의 월 내 위치
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        logSelectedDate(date)
        calendar.reloadData()
    }
    
    private func logSelectedDate(_ date: Date) {
        let calendars = Calendar.current
        
        print("Date: \(date)")
        print("Month: \(calendars.component(.month, from: date))")
        print("Day: \(calendars.component(.day, from: date))")
        
        if let expense = fakeTripExpenses[date] {
            print("지출: ₩\(Int(expense).formatted())")
        } else {
            print("데이터 없음")
        }
        
        print("==================================")
    }
}
