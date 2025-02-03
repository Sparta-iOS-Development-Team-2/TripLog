import UIKit
import SnapKit

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()
//    private let todayViewController = TodayViewController()

    private let todayViewController = TodayViewController()
    private let calendarViewController = CalendarViewController()

    private let containerView = UIView() // ✅ TodayViewController와 CalendarViewController를 담을 컨테이너 뷰

    func configure(subtitle: String, date: String, expense: String, budget: String) {
        titleDateView.configure(subtitle: subtitle, date: date)
        progressView.configure(expense: expense, budget: budget)

        setupLayout()
        applyBackgroundColor()
        
        // ✅ TodayViewController에서 지출이 변경될 때 progressView 업데이트
        todayViewController.onExpenseUpdated = { [weak self] updatedExpense in
            self?.progressView.configure(expense: updatedExpense, budget: budget)
        }
    }

    private func setupLayout() {
        // 모든 서브뷰 추가
        [titleDateView, progressView, buttonStackView, containerView].forEach {
            contentView.addSubview($0)
        }

        // `TodayViewController`와 `CalendarViewController`의 `view`를 `containerView`에 추가
        containerView.addSubview(todayViewController.view)
        containerView.addSubview(calendarViewController.view)

        // 기본적으로 `TodayViewController`를 보이게 하고 `CalendarViewController`는 숨김
        todayViewController.view.isHidden = false
        calendarViewController.view.isHidden = true

        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6).priority(.required) // 화면의 60% 차지
        }

        todayViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        calendarViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 버튼 액션 추가
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.switchToTodayView()
            },
            calendarAction: { [weak self] in
                self?.switchToCalendarView()
            }
        )
    }

    // `TodayViewController`로 전환
    private func switchToTodayView() {
        todayViewController.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    // `CalendarViewController`로 전환
    private func switchToCalendarView() {
        todayViewController.view.isHidden = true
        calendarViewController.view.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
