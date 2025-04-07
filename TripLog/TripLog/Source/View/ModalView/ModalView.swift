//
//  ModalView.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달 뷰 컨트롤러의 뷰로 쓰일 모달 뷰
final class ModalView: UIView {
    typealias ModalCashBookData = (id: UUID, tripName: String, note: String, budget: Int, departure: String, homecoming: String, state: ModalViewState)
    typealias ModalConsumptionData = (id: UUID, cashBookID: UUID, expenseDate: Date, payment: Bool, note: String, category: String, amount: Double, country: String, state: ModalViewState, exchangeRate: Double)
    
    // MARK: - Rx Properties
    
    fileprivate let cancelButtonTapped = PublishRelay<Void>()
    fileprivate let cashBookActiveButtonTapped = PublishRelay<ModalCashBookData>()
    fileprivate let consumptionActiveButtonTapped = PublishRelay<ModalConsumptionData>()
    fileprivate let categoryButtonTapped = PublishRelay<String>()
    
    private let firstTextFieldIsEmpty = BehaviorSubject<Bool>(value: true)
    private let secondTextFieldIsEmpty = BehaviorSubject<Bool>(value: true)
    private let thirdTextFieldIsEmpty = BehaviorSubject<Bool>(value: true)
    private let dateIsEmpty = BehaviorSubject<Bool>(value: false)
    
    fileprivate lazy var allSectionIsEmpty: Observable<Bool> = {
        return Observable
            .combineLatest(firstTextFieldIsEmpty,
                           secondTextFieldIsEmpty,
                           thirdTextFieldIsEmpty,
                           dateIsEmpty
            )
            .map { $0 || $1 || $2 || $3 }
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .subtitle, weight: .bold)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let buttons: ModalButtons
    
    private let firstSection: UIView
    private let secondSection: UIView
    private let thirdSection: UIView
    private let forthSection: UIView
    
    // MARK: - Properties
    
    private var state: ModalViewState
    private var cashBookID: UUID?
    private var consumptionID: UUID?
    private var expenseDate: Date?
    private var exchangeRate: [CurrencyEntity]?
    
    // MARK: - Initializer
    
    /// 모달뷰 기본 생성자
    /// - Parameter state: 모달뷰의 상태를 지정
    ///
    /// ``ModalViewState``
    init(state: ModalViewState) {
        self.state = state
        switch state {
        case .createNewCashBook, .editCashBook:
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalTextField(title: "가계부 이름", subTitle: nil, placeholder: "예: 도쿄 여행 2024", keyboardType: .default, state: .justTextField)
            self.secondSection = ModalTextField(title: "여행 국가", subTitle: nil, placeholder: "예: 일본", keyboardType: .default, state: .justTextField)
            self.thirdSection = ModalTextField(title: "예산 설정", subTitle: "원(한화)", placeholder: "0", keyboardType: .numberPad, state: .numberTextField)
            self.forthSection = ModalDateView()
            
        case .createNewConsumption, .editConsumption:
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalSegmentView()
            self.secondSection = ModalTextField(title: "지출 내용", subTitle: nil, placeholder: "예: 스시 오마카세", keyboardType: .default, state: .justTextField)
            self.thirdSection = ModalCategoryView()
            self.forthSection = ModalAmountView()
        }
        
        switch state {
        case .createNewCashBook, .createNewConsumption:
            self.buttons = ModalButtons(buttonTitle: "생성")
        case .editCashBook, .editConsumption:
            self.buttons = ModalButtons(buttonTitle: "수정")
        }
        
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowPath = self.shadowPath()
    }
    
    func configureCategoryView(_ text: String) {
        guard let categoryView = thirdSection as? ModalCategoryView else { return }
        categoryView.configurePlaceholderText(text: text)
    }

}

// MARK: - UI Setting Method

private extension ModalView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        setupModal()
        bindButtons()
    }
    
    func configureSelf() {
        self.backgroundColor = UIColor.CustomColors.Background.background
        self.applyViewShadow()
        [titleLabel,
         firstSection,
         secondSection,
         thirdSection,
         forthSection,
         buttons].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        firstSection.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        secondSection.snp.makeConstraints {
            $0.top.equalTo(firstSection.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        thirdSection.snp.makeConstraints {
            $0.top.equalTo(secondSection.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        forthSection.snp.makeConstraints {
            $0.top.equalTo(thirdSection.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        buttons.snp.makeConstraints {
            $0.top.equalTo(forthSection.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
    }
    
    /// 모달뷰의 CashBookID를 추출하는 메소드
    /// - Returns: 모달뷰의 CashBookID
    func getCashBookID() -> UUID {
        guard let cashBookID else { return UUID() }
        return cashBookID
    }
    
    /// 모달뷰의 ConsumptionID를 추출하는 메소드
    /// - Returns: 모달뷰의 ConsumptionID
    func getConsumptionID() -> UUID {
        guard let consumptionID else { return UUID() }
        return  consumptionID
    }
    
    /// 모달뷰의 지출 내역 일자를 반환하는 메소드
    /// - Returns: 지출 내역 작성 일자
    func getExpenseDate() -> Date {
        guard let expenseDate else { return Date() }
        return expenseDate
    }
    
    /// 환율을 계산해서 원화로 반환하는 메소드
    /// - Parameters:
    ///   - country: 환율을 적용할 국가 통화코드
    ///   - amount: 기준 원화
    /// - Returns: 환율을 적용한 원화
    func exchangeRateCalculation(_ country: String, _ amount: Double) -> Double {
        guard let currency = exchangeRate?.filter({ $0.currencyCode?.prefix(3) ?? "" == country }).first else { return 0 }
        debugPrint("🗓️ 현재 적용된 환율 날짜:", currency.rateDate ?? "nil")
        
        var result: Double = 0
        
        if String(currency.currencyCode?.prefix(3) ?? "") == String(Currency.JPY.rawValue.prefix(3)) ||
            String(currency.currencyCode?.prefix(3) ?? "") == String(Currency.IDR.rawValue.prefix(3))
        {
            result = amount * (currency.baseRate / 100)
        } else {
            result = amount * currency.baseRate
        }
        
        return result
    }
    
    /// 모달뷰를 세팅하는 메소드
    func setupModal() {
        switch self.state {
        case .createNewCashBook:
            if let firstSection = self.firstSection as? ModalTextField,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalDateView
            {
                firstSection.rx.textFieldIsEmpty
                    .bind(to: firstTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                secondSection.rx.textFieldIsEmpty
                    .bind(to: secondTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsEmpty
                    .bind(to: thirdTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                forthSection.rx.dateIsEmpty
                    .bind(to: dateIsEmpty)
                    .disposed(by: disposeBag)
            }
            
        case .editCashBook(data: let data):
            if let firstSection = self.firstSection as? ModalTextField,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalDateView
            {
                firstSection.configureTextField(text: data.tripName)
                secondSection.configureTextField(text: data.note)
                thirdSection.configureTextField(text: "\(data.budget)")
                forthSection.configureDate(start: data.departure, end: data.homecoming)
                
                self.cashBookID = data.id
                
                firstSection.rx.textFieldIsEmpty
                    .bind(to: firstTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                secondSection.rx.textFieldIsEmpty
                    .bind(to: secondTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsEmpty
                    .bind(to: thirdTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                forthSection.rx.dateIsEmpty
                    .bind(to: dateIsEmpty)
                    .disposed(by: disposeBag)
            }
            
        case .createNewConsumption(data: let data):
            if
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalCategoryView,
               let forthSection = self.forthSection as? ModalAmountView
            {
                self.cashBookID = data.cashBookID
                self.expenseDate = data.date
                self.exchangeRate = data.exchangeRate
                
                if let country = UserDefaults.standard.string(forKey: "lastSelectedCurrency") {
                    forthSection.configureAmountView(amount: nil, country: country)
                }
                
                secondSection.rx.textFieldIsEmpty
                    .bind(to: firstTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.categoryIsEmpty
                    .bind(to: secondTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.categoryButtonTapped
                    .bind(to: categoryButtonTapped)
                    .disposed(by: disposeBag)
                
                forthSection.rx.amountViewIsEmpty
                    .bind(to: thirdTextFieldIsEmpty)
                    .disposed(by: disposeBag)
            }
            
        case .editConsumption(data: let data, exchangeRate: let rate):
            if let firstSection = self.firstSection as? ModalSegmentView,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalCategoryView,
               let forthSection = self.forthSection as? ModalAmountView
            {
                firstSection.configureSegment(to: data.payment)
                secondSection.configureTextField(text: data.note)
                thirdSection.configurePlaceholderText(text: data.category)
                forthSection.configureAmountView(amount: data.amount, country: data.country)
                
                self.cashBookID = data.cashBookID
                self.consumptionID = data.id
                self.expenseDate = data.expenseDate
                self.exchangeRate = rate
                
                secondSection.rx.textFieldIsEmpty
                    .bind(to: firstTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.categoryIsEmpty
                    .bind(to: secondTextFieldIsEmpty)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.categoryButtonTapped
                    .bind(to: categoryButtonTapped)
                    .disposed(by: disposeBag)
                
                forthSection.rx.amountViewIsEmpty
                    .bind(to: thirdTextFieldIsEmpty)
                    .disposed(by: disposeBag)
            }
        }
    }
    
    /// 모달뷰의 가계부 데이터를 추출하는 메소드
    /// - Returns: 모달뷰 가계부 데이터
    func cashBookDataExtraction() -> ModalCashBookData? {
        switch state {
        case .createNewCashBook, .editCashBook:
            guard
                let first = firstSection as? ModalTextField,
                let second = secondSection as? ModalTextField,
                let third = thirdSection as? ModalTextField,
                let forth = forthSection as? ModalDateView
            else { return nil }
            
            let dateData = forth.datePickerExtraction()
            
            let cashBookData = (getCashBookID(),
                                first.textFieldExtraction(),
                                second.textFieldExtraction(),
                                Int(third.textFieldExtraction()) ?? 0,
                                dateData.start,
                                dateData.end,
                                state)
            
            return cashBookData
            
        default:
            return nil
        }
    }
    
    /// 모달뷰의 지출 내역 데이터를 추출하는 메소드
    /// - Returns: 모달뷰의 지출 내역 데이터
    func consumptionDataExtraction() -> ModalConsumptionData? {
        switch state {
        case .createNewConsumption, .editConsumption:
            guard
                let first = firstSection as? ModalSegmentView,
                let second = secondSection as? ModalTextField,
                let third = thirdSection as? ModalCategoryView,
                let forth = forthSection as? ModalAmountView
            else { return nil }
            
            let exchangeRate = exchangeRateCalculation(forth.currencyExtraction(), forth.amountExtraction())
            
            let consumptionData = (getConsumptionID(),
                                   getCashBookID(),
                                   getExpenseDate(),
                                   first.paymentExtraction(),
                                   second.textFieldExtraction(),
                                   third.categoryExtraction(),
                                   forth.amountExtraction(),
                                   forth.currencyExtraction(),
                                   state,
                                   exchangeRate)
        
            return consumptionData
            
        default:
            return nil
        }
    }

    /// 모달뷰의 버튼을 바인딩 하는 메소드
    func bindButtons() {
        switch state {
        case .createNewCashBook, .editCashBook:
            buttons.rx.activeButtondTapped
                .map { [weak self] _ -> ModalView.ModalCashBookData in
                    guard let data = self?.cashBookDataExtraction() else {
                        return (UUID(), "", "", 0, "", "", ModalViewState.createNewCashBook)
                    }
                    
                    return data
                }
                .bind(to: cashBookActiveButtonTapped)
                .disposed(by: disposeBag)
            
        case .createNewConsumption, .editConsumption:
            buttons.rx.activeButtondTapped
                .map { [weak self] _ -> ModalView.ModalConsumptionData in
                    guard let data = self?.consumptionDataExtraction() else {
                        return (UUID(), UUID(), Date(), false, "", "", 0, "", ModalViewState.createNewCashBook, 0)
                    }
                    
                    return data
                }
                .bind(to: consumptionActiveButtonTapped)
                .disposed(by: disposeBag)
        }
        
        buttons.rx.cancelButtondTapped
            .bind(to: cancelButtonTapped)
            .disposed(by: disposeBag)
    }

}

// MARK: - Reactive Extension

extension Reactive where Base: ModalView {
    /// active 버튼의 tap 이벤트를 방출하는 옵저버블
    var cashBookActiveButtonTapped: PublishRelay<ModalView.ModalCashBookData> {
        return base.cashBookActiveButtonTapped
    }
    
    /// active 버튼의 tap 이벤트를 방출하는 옵저버블
    var consumptionActiveButtonTapped: PublishRelay<ModalView.ModalConsumptionData> {
        return base.consumptionActiveButtonTapped
    }
    
    /// cancel 버튼의 tap 이벤트를 방출하는 옵저버블
    var cancelButtonTapped: PublishRelay<Void> {
        return base.cancelButtonTapped
    }
    
    /// 빈 값인 섹션이 있는지 검사하고 이벤트를 방출하는 옵저버블
    var checkBlankOfSections: Observable<Bool> {
        return base.allSectionIsEmpty
    }
    
    var categoryButtonTapped: PublishRelay<String> {
        return base.categoryButtonTapped
    }

}
