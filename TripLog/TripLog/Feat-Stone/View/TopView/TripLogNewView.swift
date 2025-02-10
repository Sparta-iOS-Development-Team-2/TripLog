import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 🔹 여행 요약 정보를 표시하는 뷰 (타이틀, 날짜, 예산, 진행 상태, 버튼 포함)
final class TripLogNewView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let switcherView: TripSwitcherView
    
    /// 🔹 `titleDateView`, `progressView`, `buttonStackView`를 감싸는 컨테이너 뷰
    private let tripSummaryContainerView = UIView()
    
    private let titleDateView = TitleDateView()
    let progressView = TopProgressView()
    private let buttonStackView = CustomButtonStackView()

    /// ✅ `TripSwitcherView`를 인자로 받아 초기화
    init(switcherView: TripSwitcherView) {
        self.switcherView = switcherView
        super.init(frame: .zero)
        setupLayout() // ✅ 초기화 시점에서만 호출
        setupButtonActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// ✅ 여행 정보를 설정하는 메서드
    func configure(subtitle: String, date: String, budget: String, todayVC: TodayViewController) {
        titleDateView.configure(subtitle: subtitle, date: date)
        bindToProgressView(todayVC: todayVC, budget: budget)
    }

    /// ✅ ProgressView와 TodayViewController 연결
    private func bindToProgressView(todayVC: TodayViewController, budget: String) {
        progressView.setBudget(budget)
        
        todayVC.onTotalAmountUpdated = { [weak self] totalAmount in
            self?.progressView.expense.accept(totalAmount)
        }
    }

    private func setupLayout() {
        addSubview(tripSummaryContainerView)
        addSubview(switcherView)

        /// ✅ tripSummaryContainerView 내부에 `titleDateView`, `progressView`, `buttonStackView` 추가
        [titleDateView, progressView, buttonStackView].forEach { tripSummaryContainerView.addSubview($0) }

        /// ✅ `tripSummaryContainerView` 레이아웃 설정
        tripSummaryContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonStackView.snp.bottom) // ✅ `tripSummaryContainerView`의 bottom을 명시적으로 설정
        }

        titleDateView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16) // ✅ 중복된 `leading.trailing` 제거 후 `inset` 적용
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview() // ✅ 마지막 요소이므로 `tripSummaryContainerView`의 bottom을 설정
        }

        switcherView.snp.makeConstraints {
            $0.top.equalTo(tripSummaryContainerView.snp.bottom).offset(8) // ✅ 적절한 `offset` 추가
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    /// ✅ 버튼 클릭 시 `TripSwitcherView`의 뷰 변경
    private func setupButtonActions() {
        buttonStackView.setButtonActions(
            todayAction: { [weak self] in
                self?.switcherView.showTodayView()
            },
            calendarAction: { [weak self] in
                self?.switcherView.showCalendarView()
            }
        )
    }
}
