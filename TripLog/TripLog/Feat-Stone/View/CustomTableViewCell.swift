import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()
    private let containerView = UIView()

    private var disposeBag = DisposeBag()
    private var cashBookID: UUID?
    private var todayViewController: TodayViewController?
    
    // ✅ **총 지출 금액이 변경될 때 실행될 클로저 (TopViewController로 전달)**
    var onTotalAmountUpdated: ((String) -> Void)?

    private lazy var calendarViewController: CalendarViewController = {
        return CalendarViewController(cashBook: cashBookID ?? UUID())
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none // 셀 선택 시 회색 깜박거림 방지
        setupLayout()
        applyBackgroundColor()
        containerView.clipsToBounds = true // 내부 뷰가 넘치지 않도록 설정
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func formatDateRange(_ dateRange: String) -> String {
        let dates = dateRange.split(separator: "~").map { $0.trimmingCharacters(in: .whitespaces) }
        guard dates.count == 2 else { return dateRange } // 예외 처리

        let formattedStartDate = formatDate(String(dates[0]))
        let formattedEndDate = formatDate(String(dates[1]))

        return "\(formattedStartDate) - \(formattedEndDate)"
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd" // 현재 날짜 포맷

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd" // 원하는 출력 포맷

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // 변환 실패 시 원래 값 반환
        }
    }

    // ✅ `cashBookID`를 받아서 `TodayViewController`를 동적으로 생성
    func configure(subtitle: String, date: String, budget: String, cashBookID: UUID) {
        titleDateView.configure(subtitle: subtitle, date: formatDateRange(date)) // 날짜 포맷 적용
        self.cashBookID = cashBookID

        // ✅ **기존 todayViewController 제거 후 새로 생성**
        todayViewController?.view.removeFromSuperview()
        todayViewController = TodayViewController(cashBookID: cashBookID)

        guard let todayVC = todayViewController else { return }

        // ✅ **TodayViewController의 totalAmount 값을 감지하여 ProgressView 업데이트**
        bindToProgressView(todayVC: todayVC, budget: budget)

        // ✅ **컨테이너에 TodayViewController 추가**
        containerView.addSubview(todayVC.view)
        todayVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        // ✅ **CalendarViewController 추가 (중복 방지)**
        if calendarViewController.view.superview == nil {
            containerView.addSubview(calendarViewController.view)
            calendarViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

        // 기본적으로 TodayViewController 보이도록 설정
        todayVC.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    private func bindToProgressView(todayVC: TodayViewController, budget: String) {
        disposeBag = DisposeBag() // 셀 재사용 시 기존 바인딩 해제

        // ✅ **예산 값 한 번만 설정**
        progressView.setBudget(budget)

        // ✅ **TodayViewController의 totalAmount 값을 감지하여 ProgressView의 expense 업데이트**
        todayVC.onTotalAmountUpdated = { [weak self] totalAmount in
            self?.progressView.expense.accept(totalAmount) // ✅ Rx로 값 업데이트
            self?.onTotalAmountUpdated?(totalAmount) // ✅ **TopViewController로 전달**
        }
    }

    private func setupLayout() {
        [titleDateView, progressView, buttonStackView, containerView].forEach {
            contentView.addSubview($0)
        }

        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(64)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(50)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // 버튼 액션 설정
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.showTodayView()
            },
            calendarAction: { [weak self] in
                self?.showCalendarView()
            }
        )
    }

    private func showTodayView() {
        todayViewController?.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    private func showCalendarView() {
        todayViewController?.view.isHidden = true
        calendarViewController.view.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
