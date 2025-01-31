//
//  CalendarViewController.swift
//  TripLog
//
//  Created by Jamong on 1/23/25.
//



// CalendarViewController.swift 수정
import UIKit
import RxSwift
import Then
import SnapKit
import FSCalendar

final class CalendarViewController: UIViewController {
    // MARK: - Properties
    // 캘린더 뷰
    private lazy var calendarView = CalendarView().then {
        $0.calendar.delegate = self
        $0.calendar.dataSource = self
        
        // 커스텀 셀 등록
        $0.calendar.register(CalendarCustomCell.self, forCellReuseIdentifier: "CalendarCustomCell")
    }
    
    // 커스텀 헤더 뷰
    private lazy var customHeaderView = CalendarCustomHeaderView(frame: .zero).then {
        $0.calendar = calendarView.calendar
    }
    
    // 가짜 데이터 생성
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 서브뷰 추가
        [customHeaderView, calendarView].forEach { view.addSubview($0) }
        
        customHeaderView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(customHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // 캘린더 헤더 타이틀 설정
    private func setupCalendar() {
        customHeaderView.updateTitle(date: calendarView.calendar.currentPage)
    }
    
    /// 캘린더의 현재 페이지를 지정된 날짜로 변경
    /// - Parameter date: 이동할 날짜
    func changeMonth(to date: Date) {
        calendarView.calendar.setCurrentPage(date, animated: true)
    }

    
    // 가짜 지출 데이터 생성
    private func generateFakeExpenseData() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 현재 월의 1일부터 말일까지 랜덤 지출 데이터 생성
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
        
        // 날짜 구성
        let day = Calendar.current.component(.day, from: date)
        cell.titleLabel.text = "\(day)"
        
        // 지출 데이터 표시
        if let expense = fakeTripExpenses[date] {
            cell.expenseLabel.text = (Int(expense).formatted())
            cell.expenseLabel.isHidden = false
        } else {
            cell.expenseLabel.text = nil
            cell.expenseLabel.isHidden = true
        }
        
        // 선택된 날짜만 정확히 처리
        if calendar.selectedDate == date {
            cell.contentView.backgroundColor = .systemBlue
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            cell.titleLabel.textColor = .white
            cell.expenseLabel.textColor = .white
        } else {
            let isToday = Calendar.current.isDateInToday(date)
            
            if isToday {
                cell.titleLabel.textColor = .systemBlue
            } else {
                cell.titleLabel.textColor = .label
                cell.expenseLabel.textColor = .red
            }
            
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.backgroundColor = .clear
        }
        
        return cell
    }
    
    /// 날짜가 선택되었을 때 호출되는 메서드 (데이터 확인용)
    /// - Parameters:
    ///   - calendar: 현재 FSCalendar 인스턴스
    ///   - date: 선택된 날짜
    ///   - monthPosition: 선택된 날짜의 월 내 위치
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 선택된 날짜에 대한 추가 작업 (필요한 경우)
        let calendars = Calendar.current
        
        print("Date: \(date)")
        print("Month: \(calendars.component(.month, from: date))")
        print("Day: \(calendars.component(.day, from: date))")
        
        // 지출 정보 확인
        if let expense = fakeTripExpenses[date] {
            print("지출: ₩\(Int(expense).formatted())")
        } else {
            print("데이터 없음")
        }
        
        print("==================================")
        
        calendar.reloadData()
    }
}

extension CalendarView {
    func setupCustomCalendar() {
        calendar.register(CalendarCustomCell.self, forCellReuseIdentifier: "CalendarCustomCell")
        
        calendar.appearance.do {
            // 기존 설정 유지
            $0.eventDefaultColor = .systemBlue
            $0.eventSelectionColor = .systemBlue
        }
    }
}
