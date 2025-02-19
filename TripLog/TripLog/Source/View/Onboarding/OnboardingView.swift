//
//  OnboardingView.swift
//  TripLog
//
//  Created by 장상경 on 2/9/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

/// TripLog 온보딩 뷰
final class OnboardingView: UIView {
    
    // MARK: - Properties
    
    typealias InfoData = (image: UIImage?, text: String)
    
    fileprivate let leftSwipeGesture = UISwipeGestureRecognizer().then {
        $0.direction = .left
    }
    
    fileprivate let rightSwipeGesture = UISwipeGestureRecognizer().then {
        $0.direction = .right
    }
    
    fileprivate var currentPage: Int = 0
    
    private let infoData: [InfoData] = [
        (UIImage(named: "page1"), "좌우로 밀어서\n간편하게 수정 & 삭제"),
        (UIImage(named: "page2"), "원하는 통화를 선택하고\n지출 내역을 추가"),
        (UIImage(named: "page3"), "캘린더에서 날짜를 선택하고\n지출 내역을 추가")
    ]
    
    // MARK: - UI Componeets
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "page1")
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    private let infoTextView = UIView().then {
        $0.backgroundColor = .CustomColors.Background.background
        $0.layer.shadowColor = UIColor.systemBackground.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowRadius = 5
        $0.layer.shadowOffset = .init(width: 0, height: -2)
    }
    
    private let infoLabel = UILabel().then {
        $0.font = .SCDream(size: .subtitle, weight: .regular)
        $0.textColor = .CustomColors.Text.textPrimary
        $0.numberOfLines = 3
        $0.textAlignment = .center
        $0.backgroundColor = .clear
    }
    
    fileprivate let skipButton = UIButton().then {
        $0.backgroundColor = .clear
        let title = "건너뛰기"
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.SCDream(size: .headline, weight: .medium),
            .foregroundColor: UIColor.CustomColors.Text.textSecondary
        ]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    fileprivate let activeButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .CustomColors.Accent.blue
        $0.titleLabel?.font = .SCDream(size: .display, weight: .bold)
        $0.layer.cornerRadius = 16
    }
    
    private lazy var pageControl = UIPageControl().then {
        $0.backgroundColor = .clear
        $0.currentPage = 0
        $0.numberOfPages = infoData.count
        $0.currentPageIndicatorTintColor = .CustomColors.Accent.blue
        $0.pageIndicatorTintColor = .CustomColors.Accent.blue.withAlphaComponent(0.5)
        $0.direction = .leftToRight
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoTextView.layer.shadowPath = .init(rect: infoTextView.bounds, transform: nil)
        setupInfoLabel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        infoTextView.layer.shadowColor = UIColor.label.cgColor
    }
    
    /// 현재 페이지를 변경하는 메소드
    func changeCurrentPage() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            let buttonTitle = self.currentPage == self.infoData.count - 1 ? "시작하기" : "다음"
            self.imageView.image = self.infoData[self.currentPage].image
            self.activeButton.setTitle(buttonTitle, for: .normal)
            self.skipButton.isHidden = self.currentPage == self.infoData.count - 1 ? true : false
            self.setupInfoLabel()
            self.pageControl.currentPage = self.currentPage
            self.layoutIfNeeded()
        }
    }
    
    /// 현재 페이지를 스와이프 방향에 따라 변경하는 메소드
    /// - Parameter direction: 스와이프 방향
    func changePageInDirection(_ direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .right:
            if currentPage > 0 {
                currentPage -= 1
            }
            
        case .left:
            if currentPage < infoData.count - 1 {
                currentPage += 1
            }
            
        default: break
        }
    }
    
}

// MARK: - UI Setting Method

private extension OnboardingView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        addSwipeAction()
    }
    
    func configureSelf() {
        backgroundColor = .CustomColors.Background.background
        [imageView, infoTextView, pageControl, infoLabel, activeButton, skipButton].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let padding: CGFloat = window.safeAreaInsets.bottom == 0 ? 50 : 0
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(padding)
        }
        
        infoTextView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(280 - padding)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(infoTextView).inset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        infoLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(pageControl.snp.bottom).offset(24)
            $0.height.equalTo(50)
        }
        
        activeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(56)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(50)
        }
        
        skipButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(activeButton)
            $0.height.equalTo(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        }
    }
    
    func setupInfoLabel() {
        infoLabel.attributedText = makeBoldAttributedText(for: infoData[currentPage].text)
    }
    
    func addSwipeAction() {
        self.addGestureRecognizer(leftSwipeGesture)
        self.addGestureRecognizer(rightSwipeGesture)
    }
    
    func makeBoldAttributedText(for text: String) -> NSMutableAttributedString {
        let boldParts = ["수정", "삭제", "통화를", "날짜를", "선택"]
        let attributedString = NSMutableAttributedString(string: text)
        let boldFont = UIFont.SCDream(size: .subtitle, weight: .bold)

        boldParts.forEach { boldPart in
            let range = (text as NSString).range(of: boldPart)
            if range.location != NSNotFound { // 존재하는 경우에만 적용
                attributedString.addAttribute(.font, value: boldFont, range: range)
            }
        }

        return attributedString
    }

    
}

// MARK: - Reactive Extension

extension Reactive where Base: OnboardingView {
    /// "시작하기" 버튼의 탭 이벤트를 방출하는 메소드
    var activeButtonTapped: Observable<Int> {
        return base.activeButton.rx.tap
            .map {
                return base.currentPage
            }
    }
    
    /// "건너뛰기" 버튼의 탭 이벤트를 방출하는 메소드
    var skipButtonTapped: ControlEvent<Void> {
        return base.skipButton.rx.tap
    }
    
    /// 왼쪽 스와이프 액션이 발생했을 때, 현재 페이지를 +1 하여 이벤트로 방출하는 메소드
    var leftSwipeAction: Observable<Int> {
        return base.leftSwipeGesture.rx.event
            .map { swipe -> Int in
                base.changePageInDirection(swipe.direction)
                return base.currentPage
            }.asObservable()
    }
    
    /// 오른쪽 스와이프 액션이 발생했을 때, 현재 페이지를 -1 하여 이벤트로 방출하는 메소드
    var rightSwipeAction: Observable<Int> {
        return base.rightSwipeGesture.rx.event
            .map { swipe -> Int in
                base.changePageInDirection(swipe.direction)
                return base.currentPage
            }
    }
}
