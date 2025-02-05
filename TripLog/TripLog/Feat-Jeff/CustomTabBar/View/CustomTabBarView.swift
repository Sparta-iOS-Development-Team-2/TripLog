//
//  CustomTabBarView.swift
//  TripLog
//
//  Created by jae hoon lee on 1/27/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

enum TabBarState {
    case cashBookList
    case setting
}

final class TabBarView: UIView {
    
    private var disposeBag = DisposeBag()
    let cashBookTapped = PublishRelay<Void>()
    let settingTapped = PublishRelay<Void>()
    let tabBarAddButtonTapped = PublishRelay<Void>()
    
    // 탭바 아이템 제스처 생성
    private let cashBookTap = UITapGestureRecognizer()
    private let settingTap = UITapGestureRecognizer()
    
    private let cashBookImageView = UIImageView().then {
        $0.image = UIImage(systemName: "book")
        $0.tintColor = UIColor.CustomColors.Accent.blue
        $0.backgroundColor = .clear
    }
    
    private let cashBookLabel = UILabel().then {
        $0.text = "가계부"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.CustomColors.Accent.blue
        $0.textAlignment = .center
    }
    
    private let cashBookVerticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let cashBookTabView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let settingImageView = UIImageView().then {
        $0.image = UIImage(systemName: "gearshape")
        $0.tintColor = UIColor.CustomColors.Accent.blue
        $0.backgroundColor = .clear
    }
    
    private let settingLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.CustomColors.Accent.blue
        $0.textAlignment = .center
    }
    
    private let settingVerticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let settingTabView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let tabBarAddButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Border.plus
        $0.backgroundColor = UIColor.CustomColors.Accent.blue
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupUIConstraints()
        setupGestureRecognizers()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
    
            tabBarAddButton.applyTabBarButtonStyle()
            
        }
    }
}

//MARK: - Private Method
private extension TabBarView {
    
    /// setupUI
    func setupUI() {
        
        // 탭바 추가 버튼 스타일 적용
        tabBarAddButton.applyTabBarButtonStyle()
                
        cashBookTabView.addSubview(cashBookVerticalStackView)
        settingTabView.addSubview(settingVerticalStackView)
        
        [
            cashBookImageView,
            cashBookLabel
        ].forEach { cashBookVerticalStackView.addArrangedSubview($0) }
        
        [
            settingImageView,
            settingLabel
        ].forEach { settingVerticalStackView.addArrangedSubview($0) }
        
        [
            cashBookTabView,
            tabBarAddButton,
            settingTabView
        ].forEach { addSubview($0) }
    }
    
    /// setupUIConstraints
    func setupUIConstraints() {
        
        cashBookTabView.snp.makeConstraints {
            //중앙에서 왼쪽으로 50% 이동
            $0.centerX.equalToSuperview().multipliedBy(0.5)
            $0.verticalEdges.equalToSuperview()
        }
        
        cashBookVerticalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.width.equalTo(50)
        }
        
        tabBarAddButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
            $0.top.equalToSuperview().offset(-24)
        }
        
        settingTabView.snp.makeConstraints {
            //중앙에서 오른쪽으로 50% 이동
            $0.centerX.equalToSuperview().multipliedBy(1.5)
            $0.verticalEdges.equalToSuperview()
        }
        
        settingVerticalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.width.equalTo(50)
        }
    }
    
    /// Gesture Recognizer 추가
    func setupGestureRecognizers() {
       
        cashBookTabView.addGestureRecognizer(cashBookTap)
        settingTabView.addGestureRecognizer(settingTap)
    }
    
    /// 탭바 아이템, 버튼 바인딩
    func bind() {
        
        // 가계부 리스트 탭
        cashBookTap.rx.event
            .map { _ in }
            .bind(to: cashBookTapped)
            .disposed(by: disposeBag)
        
        // 설정 탭
        settingTap.rx.event
            .map { _ in }
            .bind(to: settingTapped)
            .disposed(by: disposeBag)
        
        // 탭바 추가 버튼
        tabBarAddButton.rx.tap
            .bind(to: tabBarAddButtonTapped)
            .disposed(by: disposeBag)
    }
}

//MARK: - Method
extension TabBarView {
    
    /// 탭바 상태에 따른 탭바 아이템 컬러 변경
    func updateTabItem(for state: TabBarState) {
        switch state {
        case .cashBookList:
            cashBookImageView.tintColor = UIColor.CustomColors.Accent.blue
            cashBookImageView.image = UIImage(systemName: "book.fill")
            cashBookLabel.textColor = UIColor.CustomColors.Accent.blue
            settingImageView.tintColor = UIColor.CustomColors.Text.textSecondary
            settingImageView.image = UIImage(systemName: "gearshape")
            settingLabel.textColor = UIColor.CustomColors.Text.textSecondary
            
        case .setting:
            settingImageView.tintColor = UIColor.CustomColors.Accent.blue
            settingImageView.image = UIImage(systemName: "gearshape.fill")
            settingLabel.textColor = UIColor.CustomColors.Accent.blue
            cashBookImageView.tintColor = UIColor.CustomColors.Text.textSecondary
            cashBookImageView.image = UIImage(systemName: "book")
            cashBookLabel.textColor = UIColor.CustomColors.Text.textSecondary
        }
    }
}
