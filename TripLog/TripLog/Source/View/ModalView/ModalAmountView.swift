//
//  ModalAmountView.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달뷰에서 금액을 입력하는 공용 컴포넌츠
final class ModalAmountView: UIView {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let title = UILabel().then {
        $0.text = "금액"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let currencyButton = UIButton().then {
        $0.setTitle("KRW(원)", for: .normal)
        $0.setTitleColor(.CustomColors.Accent.blue, for: .normal)
        $0.titleLabel?.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.tintColor = .CustomColors.Accent.blue
        $0.backgroundColor = .clear
    }
    
    fileprivate let textField = UITextField().then {
        $0.setPlaceholder(title: "0", color: .Light.r400)
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = UIColor.Dark.base
        $0.borderStyle = .none
        $0.clipsToBounds = true
        $0.applyTextFieldStyle()
        $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 12))
        $0.rightViewMode = .always
        $0.autocapitalizationType = .none
        $0.keyboardType = .decimalPad
    }
    
    private let helpButton = UIButton().then {
        $0.setTitle("?", for: .normal)
        $0.setTitleColor(.CustomColors.Accent.blue, for: .normal)
        $0.titleLabel?.font = .SCDream(size: .body, weight: .bold)
        $0.applyBackgroundColor()
        $0.applyTextFieldStroke()
        $0.applyCornerRadius(9)
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.textField.applyTextFieldStroke()
            self.helpButton.applyTextFieldStroke()
        }
    }
    
    /// 금액 입력 뷰를 세팅하는 메소드
    /// - Parameters:
    ///   - amount: 금액(빈 값일 수도 있음)
    ///   - currency: 통화
    func configureAmountView(amount: Double?, country: String) {
        self.textField.text = amount?.formattedWithFormatter
        
        let currency = Currency.allCurrencies.filter { String($0.prefix(3)) == country }.first
        self.currencyButton.setTitle(currency ?? "", for: .normal)
    }
    
    /// 금액뷰의 데이터를 추출하는 메소드
    /// - Returns: 금액
    func amountExtraction() -> Double {
        guard
            let text = textField.text,
            let amount = Double(text.replacingOccurrences(of: ",", with: ""))
        else { return 0 }
        
        return amount
    }
    
    /// 모달뷰의 금액뷰에서 통화 정보를 추출하는 메소드
    /// - Returns: 통화 정보
    func currencyExtraction() -> String {
        guard let currency = currencyButton.titleLabel?.text else { return "" }
        return String(currency.prefix(3))
    }
    
}

// MARK: - UI Setting Method

private extension ModalAmountView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        configureMenuForButton()
        bind()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, helpButton, currencyButton, textField].forEach { self.addSubview($0) }
    }
    
    /// 통화 선택 버튼에 메뉴 뷰를 추가하는 메소드
    func configureMenuForButton() {
        // 메뉴 항목 생성
        let children: [UIAction] = {
            var childrens: [UIAction] = []
            
            Currency.allCurrencies.forEach { currency in
                let action = UIAction(title: currency, handler: { [weak self] _ in
                    self?.currencyButton.setTitle(currency, for: .normal)
                })
                childrens.append(action)
            }
            return childrens
        }()
        
        // UIMenu 생성
        let menu = UIMenu(title: "환율 선택", options: .displayInline, children: children)
        
        // UIButton에 메뉴 연결
        currencyButton.menu = menu
        currencyButton.showsMenuAsPrimaryAction = true // 버튼 클릭 시 메뉴 표시
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        helpButton.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.leading.equalTo(title.snp.trailing).offset(5)
            $0.width.height.equalTo(18)
        }
        
        currencyButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(title)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        textField.rx.text.orEmpty
            .map { self.filterInput($0) } // 입력값 필터링
            .map { self.formatInput($0) } // 입력값 포맷팅
            .map { self.formatNumber($0) }
            .bind(to: textField.rx.text) // 필터링된 값 적용
            .disposed(by: disposeBag)
        
        helpButton.rx.tap
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                let recentRateDate = Date.caculateDate()
                PopoverManager.showPopover(from: owner.helpButton,
                                           title: "현재의 환율은 \(recentRateDate) 환율입니다.",
                                           subTitle: "한국 수출입 은행에서 제공하는 가장 최근 환율정보입니다.",
                                           width: 170,
                                           height: 60,
                                           arrow: .down)
            }.disposed(by: disposeBag)
    }
    
    /// 소수점을 1개만 입력할 수 있도록 필터링 하는 메소드
    /// - Parameter input: 필터링할 텍스트
    /// - Returns: 필터링된 텍스트
    func filterInput(_ input: String) -> String {
        let components = input.components(separatedBy: ".")
        if components.count > 2 {
            return components.dropLast().joined(separator: ".") // 마지막 `.` 제거
        } else {
            return input
        }
    }
    
    /// 소수점 이후로 2자리 수 까지만 입력할 수 있도록 포매팅하는 메소드
    /// - Parameter input: 포매팅할 텍스트
    /// - Returns: 포매팅된 텍스트
    func formatInput(_ input: String) -> String {
        if input.contains(".") {
            let components = input.split(separator: ".")
            
            if components.count > 1 {
                let integerPart = String(components.first ?? "")
                let decimalPart = String(components.last ?? "").prefix(2)
                
                return "\(integerPart).\(decimalPart)"
            } else {
                guard input.first != "." else { return String(input.prefix(3)) }
                return input
            }
            
        } else {
            return input
        }
    }
    
    func formatNumber(_ text: String) -> String {
        guard let number = Double(text.replacingOccurrences(of: ",", with: "")) else { return text }
        return number.formattedWithFormatter
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: ModalAmountView {
    /// 금액뷰의 텍스트필드가 비었는지 확인하는 옵저버블
    var amountViewIsEmpty: Observable<Bool> {
        return base.textField.rx.text.orEmpty
            .map { Double($0.replacingOccurrences(of: ",", with: "")) == nil }
            .distinctUntilChanged()
            .asObservable()
    }
}
