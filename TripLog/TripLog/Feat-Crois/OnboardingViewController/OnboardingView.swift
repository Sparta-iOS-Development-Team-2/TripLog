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
    
    fileprivate let leftSwipeGesture = UISwipeGestureRecognizer().then {
        $0.direction = .left
    }
    
    fileprivate let rightSwipeGesture = UISwipeGestureRecognizer().then {
        $0.direction = .right
    }
    
    fileprivate var currentPage: Int = 0
    
    // MARK: - UI Componeets
    
    private let images: [UIImage?] = [
        UIImage(named: "page1"),
        UIImage(named: "page2"),
        UIImage(named: "page3")
    ]
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "page1")
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    private let infoTextView = UIView().then {
        $0.backgroundColor = .CustomColors.Background.background
        $0.layer.shadowColor = UIColor.systemBackground.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowRadius = 10
        $0.layer.shadowOffset = .init(width: 0, height: -2)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "test"
        $0.font = .SCDream(size: .subtitle, weight: .regular)
        $0.textColor = .CustomColors.Text.textPrimary
        $0.numberOfLines = 3
        $0.textAlignment = .center
        $0.backgroundColor = .clear
    }
    
    fileprivate let activeButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .CustomColors.Accent.blue
        $0.titleLabel?.font = .SCDream(size: .title, weight: .bold)
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }
    
    private lazy var pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .CustomColors.Accent.blue
        $0.pageIndicatorTintColor = .CustomColors.Accent.blue.withAlphaComponent(0.5)
        $0.backgroundColor = .clear
        $0.currentPage = 0 // 초기값 세팅
        $0.numberOfPages = images.count // 최대 페이지 수
    }
    
    // MARK: - Initializer
    
    init(infoText: String) {
        super.init(frame: .zero)
        infoLabel.text = infoText
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoTextView.layer.shadowPath = .init(rect: infoTextView.bounds, transform: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        infoTextView.layer.shadowColor = UIColor.systemBackground.cgColor
    }
    
    /// 현재 페이지를 변경하는 메소드
    func changeCurrentPage() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.imageView.image = self.images[self.currentPage]
            self.pageControl.currentPage = self.currentPage
            self.activeButton.isHidden = self.currentPage == (self.images.count - 1) ? false : true
            self.layoutIfNeeded()
        }
    }
    
    /// 현재 페이지를 스와이프 방향에 따라 변경하는 메소드
    /// - Parameter direction: 스와이프 방향
    fileprivate func changePageInDirection(_ direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .right:
            if currentPage > 0 {
                currentPage -= 1
            }
            
        case .left:
            if currentPage < images.count - 1 {
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
        [imageView, infoTextView, infoLabel, pageControl, activeButton].forEach { addSubview($0) }
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
            $0.height.equalTo(360 - padding)
        }
        
        infoLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(infoTextView).offset(32)
            $0.height.equalTo(50)
        }
        
        pageControl.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(infoTextView).offset(8)
            $0.height.equalTo(32)
        }
        
        activeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(64)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        }
    }
    
    func addSwipeAction() {
        self.addGestureRecognizer(leftSwipeGesture)
        self.addGestureRecognizer(rightSwipeGesture)
    }
    
    func infoLabelConfig(_ text: String) -> NSMutableAttributedString {
        let fullText = text
        let boldParts = ["수정", "삭제", "통화를", "날짜를", "선택"]
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let boldFont = UIFont.SCDream(size: .subtitle, weight: .bold)
        
        boldParts.forEach { boldPart in
            let range = (fullText as NSString).range(of: boldPart)
            attributedString.addAttribute(.font, value: boldFont, range: range)
        }
        
        return attributedString
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: OnboardingView {
    /// "시작하기" 버튼의 탭 이벤트를 방출하는 메소드
    var activeButtonTapped: ControlEvent<Void> {
        return base.activeButton.rx.tap
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
