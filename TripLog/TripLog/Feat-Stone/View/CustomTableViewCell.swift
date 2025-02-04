import UIKit
import SnapKit
import CoreData

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()

    private var todayViewController: TodayViewController? // ✅ TodayViewController를 저장할 변수
    private let calendarViewController = CalendarViewController()

    private let containerView = UIView() // ✅ TodayViewController와 CalendarViewController를 담을 컨테이너 뷰

    // ✅ CoreData 컨텍스트를 받도록 수정
    func configure(subtitle: String, date: String, expense: String, budget: String, context: NSManagedObjectContext) {
        titleDateView.configure(subtitle: subtitle, date: date)

        setupLayout()
        applyBackgroundColor()

        // ✅ TodayViewController를 초기화하면서 CoreData 컨텍스트 전달
        todayViewController = TodayViewController(context: context)
        guard let todayVC = todayViewController else { return }

        // ✅ 초기 총 금액을 가져와 ProgressView 업데이트
        let initialExpense = todayVC.viewModel.totalAmount.value
        progressView.configure(expense: initialExpense, budget: budget)

        // ✅ TodayViewController에서 지출이 변경될 때 progressView 업데이트
        todayVC.onExpenseUpdated = { [weak self] updatedExpense in
            DispatchQueue.main.async {
                self?.progressView.configure(expense: updatedExpense, budget: budget)
            }
        }

        // ✅ TodayViewController의 뷰를 containerView에 추가
        containerView.addSubview(todayVC.view)
        todayVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        // ✅ CalendarViewController의 뷰도 containerView에 추가
        containerView.addSubview(calendarViewController.view)
        calendarViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 기본적으로 `TodayViewController`를 보이게 하고 `CalendarViewController`는 숨김
        todayVC.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    private func setupLayout() {
        // 모든 서브뷰 추가
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

        // 버튼 액션 설정
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.switchCurrentView()
            },
            calendarAction: { [weak self] in
                self?.switchCurrentView()
            }
        )
    }

    // 현재 활성화된 뷰를 전환
    private func switchCurrentView() {
        todayViewController?.view.isHidden.toggle()
        calendarViewController.view.isHidden.toggle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
