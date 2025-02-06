import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()
    private let containerView = UIView() // TodayViewController와 CalendarViewController를 담을 컨테이너 뷰

    private var disposeBag = DisposeBag()
    private var cashBookID: UUID?

    // ✅ TodayViewController & CalendarViewController는 lazy var로 최초 1회만 생성
    private lazy var todayViewController: TodayViewController = {
        let vc = TodayViewController(cashBookID: cashBookID ?? UUID())
        return vc
    }()

    private lazy var calendarViewController: CalendarViewController = {
        return CalendarViewController()
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

    // ✅ `context` 없이 `cashBookID`만 받도록 수정
    func configure(subtitle: String, date: String, budget: String, cashBookID: UUID) {
        titleDateView.configure(subtitle: subtitle, date: date)
        self.cashBookID = cashBookID

        // ✅ TodayViewController의 cashBookID 업데이트 (새로운 객체 생성 없이 기존 인스턴스 활용)
        todayViewController.viewModel.input.fetchTrigger.accept(cashBookID)

        // ✅ ProgressView와 TodayViewController 데이터 바인딩
        bindToProgressView(budget: budget)

        // ✅ 컨테이너에 뷰 추가 (중복 추가 방지)
        if todayViewController.view.superview == nil {
            containerView.addSubview(todayViewController.view)
            todayViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

        if calendarViewController.view.superview == nil {
            containerView.addSubview(calendarViewController.view)
            calendarViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

        // 기본적으로 TodayViewController 보이도록 설정
        todayViewController.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    // ✅ ProgressView와 TodayViewController 데이터 바인딩
    private func bindToProgressView(budget: String) {
        disposeBag = DisposeBag() // 셀 재사용 시 기존 바인딩 해제

        todayViewController.viewModel.output.totalAmount
            .drive(onNext: { [weak self] updatedExpense in
                self?.progressView.configure(expense: updatedExpense, budget: budget)
            })
            .disposed(by: disposeBag)
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
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6).priority(.required)
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
        todayViewController.view.isHidden = false
        calendarViewController.view.isHidden = true
    }

    private func showCalendarView() {
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
