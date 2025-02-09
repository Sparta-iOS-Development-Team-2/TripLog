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
    
    private let cashBookTabButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        // 배경색과 텍스트색 설정
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = UIColor.CustomColors.Accent.blue
        
        // 텍스트와 폰트 설정
        config.attributedTitle = AttributedString("가계부", attributes: AttributeContainer([
            .font: UIFont.SCDream(size: .body, weight: .bold)
        ]))
        
        // 이미지와 위치 설정
        config.image = UIImage(systemName: "book")
        config.imagePadding = 5
        config.imagePlacement = .top
        
        $0.configuration = config
    }
           
    private let settingTabButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        // 배경색과 텍스트색 설정
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = UIColor.CustomColors.Accent.blue
        
        // 텍스트와 폰트 설정
        config.attributedTitle = AttributedString("설정", attributes: AttributeContainer([
            .font: UIFont.SCDream(size: .body, weight: .bold)
        ]))
        
        // 이미지와 위치 설정
        config.image = UIImage(systemName: "gearshape")
        config.imagePadding = 5
        config.imagePlacement = .top
        
        $0.configuration = config
    }
    
    let tabBarAddButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.CustomColors.Background.background
        $0.backgroundColor = UIColor.CustomColors.Accent.blue
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupUIConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
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
        
        [
            cashBookTabButton,
            tabBarAddButton,
            settingTabButton
        ].forEach { addSubview($0) }
    }
    
    /// setupUIConstraints
    func setupUIConstraints() {
        
        cashBookTabButton.snp.makeConstraints {
            //중앙에서 왼쪽으로 50% 이동
            $0.centerX.equalToSuperview().multipliedBy(0.5)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(60)
        }
        
        tabBarAddButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
            $0.top.equalToSuperview().offset(-24)
        }
        
        settingTabButton.snp.makeConstraints {
            //중앙에서 오른쪽으로 50% 이동
            $0.centerX.equalToSuperview().multipliedBy(1.5)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(60)
        }
        
    }
    
    /// 탭바 아이템 바인딩
    func bind() {
        
        // 가계부 리스트 탭
        cashBookTabButton.rx.tap
            .map { _ in }
            .bind(to: cashBookTapped)
            .disposed(by: disposeBag)
        
        // 설정 탭
        settingTabButton.rx.tap
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
            cashBookTabButton.updateConfiguration { config in
                config.baseForegroundColor = UIColor.CustomColors.Accent.blue
                config.image = UIImage(systemName: "book.fill")
            }
            settingTabButton.updateConfiguration { config in
                config.baseForegroundColor = UIColor.CustomColors.Text.textSecondary
                config.image = UIImage(systemName: "gearshape")
            }
            
        case .setting:
            cashBookTabButton.updateConfiguration { config in
                config.baseForegroundColor = UIColor.CustomColors.Text.textSecondary
                config.image = UIImage(systemName: "book")
            }
            settingTabButton.updateConfiguration { config in
                config.baseForegroundColor = UIColor.CustomColors.Accent.blue
                config.image = UIImage(systemName: "gearshape.fill")
            }
        }
    }
    
}


