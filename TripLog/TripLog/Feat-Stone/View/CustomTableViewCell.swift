import UIKit
import SnapKit
import CoreData

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()
    private let containerView = UIView() // TodayViewController와 CalendarViewController를 담을 컨테이너 뷰
    
    private var todayViewController: TodayViewController?
    private let calendarViewController = CalendarViewController()
    
    private var context: NSManagedObjectContext? // CoreData 컨텍스트 저장

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

    // CoreData 컨텍스트를 받도록 수정 & 뷰 중복 추가 방지
    func configure(subtitle: String, date: String, expense: String, budget: String, context: NSManagedObjectContext) {
        self.context = context // 컨텍스트 저장
        titleDateView.configure(subtitle: subtitle, date: date)

        // 기존 TodayViewController 제거 후 다시 추가 (재사용 방지)
        todayViewController?.view.removeFromSuperview()
        todayViewController = TodayViewController(context: context)

        guard let todayVC = todayViewController else { return }

        // 초기 총 금액을 가져와 ProgressView 업데이트
        let initialExpense = todayVC.viewModel.totalAmount.value
        progressView.configure(expense: initialExpense, budget: budget)

        // 지출 변경 감지하여 progressView 업데이트
        todayVC.onExpenseUpdated = { [weak self] updatedExpense in
            DispatchQueue.main.async {
                self?.progressView.configure(expense: updatedExpense, budget: budget)
            }
        }

        // TodayViewController 추가
        containerView.addSubview(todayVC.view)
        todayVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        // CalendarViewController 추가 (중복 제거)
        calendarViewController.view.removeFromSuperview()
        containerView.addSubview(calendarViewController.view)
        calendarViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 기본적으로 TodayViewController 보이도록 설정
        todayVC.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    private func setupLayout() {
        // 모든 서브뷰 추가
        [titleDateView, progressView, buttonStackView, containerView].forEach {
            contentView.addSubview($0)
        }
        contentView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(8)
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
            $0.leading.trailing.bottom.equalToSuperview().inset(16) // 좌우 여백 추가
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6).priority(.required) // 화면의 60% 차지
        }

        // 버튼 액션 설정 (더 명확한 전환 방식 적용)
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.showTodayView()
            },
            calendarAction: { [weak self] in
                self?.showCalendarView()
            }
        )
    }

    // TodayViewController 활성화
    private func showTodayView() {
        todayViewController?.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    // CalendarViewController 활성화
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
