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
    
    fileprivate let activeButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .CustomColors.Accent.blue
        $0.titleLabel?.font = .SCDream(size: .title, weight: .bold)
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 현재 페이지를 변경하는 메소드
    func changeCurrentPage() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
            self.imageView.image = self.images[self.currentPage]
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
        [imageView, activeButton].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().inset(100)
        }
    }
    
    func addSwipeAction() {
        self.addGestureRecognizer(leftSwipeGesture)
        self.addGestureRecognizer(rightSwipeGesture)
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
