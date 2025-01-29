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

class TabBarView: UIView {
    
    private var buttonWidth: CGFloat = 0
    private var sideEmptyInset: CGFloat = 0
    private var buttonSpacing: CGFloat = 0
    
    private var disposeBag = DisposeBag()
    
    private let cashBookImageView = UIImageView().then {
        $0.image = UIImage(systemName: "book")
        $0.tintColor = .blue
    }
    
    private let cashBookLabel = UILabel().then {
        $0.text = "가계부"
        $0.textColor = .blue
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 10, weight: .medium)
    }
    
    private let cashBookVerticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let cashBookTabView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    //MARK: -
    private let settingImageView = UIImageView().then {
        $0.image = UIImage(systemName: "gearshape")
        $0.tintColor = .blue
    }
    
    private let settingLabel = UILabel().then {
        $0.text = "설정"
        $0.textColor = .blue
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 10, weight: .medium)
    }
    
    private let settingVerticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let settingTabView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    //MARK: -
    
    private let addButton = UIButton().then {
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = (64 - 10) / 2
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.tintColor = .white
    }
    
    private let addButtonView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
    }
    
    //MARK: -
    
    let cashBookTapped = PublishSubject<Void>()
    let settingTapped = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupGestureRecognizers()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TabBarView {
    
    private func setupGestureRecognizers() {
        let cashBookTap = UITapGestureRecognizer()
        let settingTap = UITapGestureRecognizer()
        
        cashBookTabView.addGestureRecognizer(cashBookTap)
        settingTabView.addGestureRecognizer(settingTap)
        
        // RxSwift로 Gesture Recognizer 이벤트 바인딩
        cashBookTap.rx.event
            .map { _ in }
            .bind(to: cashBookTapped)
            .disposed(by: disposeBag)
        
        settingTap.rx.event
            .map { _ in }
            .bind(to: settingTapped)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        [
            cashBookImageView,
            cashBookLabel
        ].forEach { cashBookVerticalStackView.addArrangedSubview($0) }
        
        
        [
            settingImageView,
            settingLabel
        ].forEach { settingVerticalStackView.addArrangedSubview($0) }
        
        cashBookTabView.addSubview(cashBookVerticalStackView)
        settingTabView.addSubview(settingVerticalStackView)
        addButtonView.addSubview(addButton)
        
        [
            cashBookTabView,
            addButtonView,
            settingTabView
        ].forEach { addSubview($0) }
    }
    
    // 전달받은 값을 저장하고 레이아웃 업데이트
    func configureLayout(buttonWidth: CGFloat, sideEmptyInset: CGFloat, buttonSpacing: CGFloat) {
        self.buttonWidth = buttonWidth
        self.sideEmptyInset = sideEmptyInset
        self.buttonSpacing = buttonSpacing
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // 가계부 탭뷰
        cashBookTabView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(60)
            $0.verticalEdges.equalToSuperview()
        }
        
        cashBookVerticalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.width.equalTo(50)
        }
        
        // 플로팅 버튼
        addButtonView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
            $0.top.equalToSuperview().offset(-24)
        }
        
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
        
        // 설정 탭뷰
        settingTabView.snp.makeConstraints {
            $0.leading.equalTo(cashBookTabView.snp.trailing).offset(buttonWidth)
            $0.trailing.equalToSuperview().inset(60)
            $0.verticalEdges.equalToSuperview()
        }
        
        settingVerticalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.width.equalTo(50)
        }
        
        // 버튼 간격을 buttonWidth 값으로 적용 (가계부 <-> 설정 사이)
        settingTabView.snp.makeConstraints {
            $0.leading.equalTo(cashBookTabView.snp.trailing).offset(buttonWidth)
        }
    }
}

