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
    typealias ModalCashBookData = (tripName: String, note: String, budget: Int,departure: String, homecoming: String)
    typealias ModalConsumptionData = (payment: Bool, note: String, category: String, amount: Double)
    
    // MARK: - Rx Properties
    
    fileprivate let cancelButtonTapped = PublishRelay<Void>()
    fileprivate let cashBookActiveButtonTapped = PublishRelay<ModalCashBookData>()
    fileprivate let consumptionActiveButtonTapped = PublishRelay<ModalConsumptionData>()
    
    private let firstTextFieldIsBlank = BehaviorSubject<Bool>(value: true)
    private let secondTextFieldIsBlank = BehaviorSubject<Bool>(value: true)
    private let thirdTextFieldIsBlank = BehaviorSubject<Bool>(value: true)
    private let dateIsBlank = BehaviorSubject<Bool>(value: false)
    
    fileprivate lazy var allSectionIsBlank: Observable<Bool> = {
        return Observable
            .combineLatest(firstTextFieldIsBlank,
                           secondTextFieldIsBlank,
                           thirdTextFieldIsBlank,
                           dateIsBlank
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
    private var id: UUID?
    
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
            self.firstSection = ModalTextField(title: "가계부 이름", subTitle: nil, placeholder: "예: 도쿄 여행 2024", keyboardType: .default)
            self.secondSection = ModalTextField(title: "여행 국가", subTitle: nil, placeholder: "예: 일본", keyboardType: .default)
            self.thirdSection = ModalTextField(title: "예산 설정", subTitle: "원(한화)", placeholder: "0", keyboardType: .numberPad)
            self.forthSection = ModalDateView()
            self.buttons = ModalButtons(buttonTitle: "생성")
            
        case .createNewConsumption, .editConsumption:
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalSegmentView()
            self.secondSection = ModalTextField(title: "지출 내용", subTitle: nil, placeholder: "예: 스시 오마카세", keyboardType: .default)
            self.thirdSection = ModalTextField(title: "카테고리", subTitle: nil, placeholder: "예: 식비", keyboardType: .default)
            self.forthSection = ModalAmoutView()
            self.buttons = ModalButtons(buttonTitle: "생성")
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
    
    /// 모달뷰의 현재 상태를 반환하는 메소드
    /// - Returns: 모달뷰의 현재 state
    func checkModalStatus() -> ModalViewState {
        return self.state
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
    
    /// 모달뷰를 세팅하는 메소드
    func setupModal() {
        switch self.state {
        case .createNewCashBook:
            if let firstSection = self.firstSection as? ModalTextField,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalDateView
            {
                firstSection.rx.textFieldIsBlank
                    .bind(to: firstTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                secondSection.rx.textFieldIsBlank
                    .bind(to: secondTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsBlank
                    .bind(to: thirdTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                forthSection.rx.dateIsBlank
                    .bind(to: dateIsBlank)
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
                
                firstSection.rx.textFieldIsBlank
                    .bind(to: firstTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                secondSection.rx.textFieldIsBlank
                    .bind(to: secondTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsBlank
                    .bind(to: thirdTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                forthSection.rx.dateIsBlank
                    .bind(to: dateIsBlank)
                    .disposed(by: disposeBag)
            }
            
        case .createNewConsumption:
            if
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalAmoutView
            {
                secondSection.rx.textFieldIsBlank
                    .bind(to: firstTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsBlank
                    .bind(to: secondTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                forthSection.rx.isBlank
                    .bind(to: thirdTextFieldIsBlank)
                    .disposed(by: disposeBag)
            }
            
        case .editConsumption(data: let data):
            if let firstSection = self.firstSection as? ModalSegmentView,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalAmoutView
            {
                firstSection.configureSegment(to: data.payment)
                secondSection.configureTextField(text: data.note)
                thirdSection.configureTextField(text: data.category)
                forthSection.configureAmoutView(amout: data.amount, currency: Currency.KRW)
                
                secondSection.rx.textFieldIsBlank
                    .bind(to: firstTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                thirdSection.rx.textFieldIsBlank
                    .bind(to: secondTextFieldIsBlank)
                    .disposed(by: disposeBag)
                
                forthSection.rx.isBlank
                    .bind(to: thirdTextFieldIsBlank)
                    .disposed(by: disposeBag)
            }
        }
    }
    
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
            
            let cashBookData = (first.textFieldExtraction(),
                                second.textFieldExtraction(),
                                Int(third.textFieldExtraction()) ?? 0,
                                dateData.start,
                                dateData.end)
            
            return cashBookData
            
        default:
            return nil
        }
    }
    
    func consumptionDataExtraction() -> ModalConsumptionData? {
        switch state {
        case .createNewConsumption, .editConsumption:
            guard
                let first = firstSection as? ModalSegmentView,
                let second = secondSection as? ModalTextField,
                let third = thirdSection as? ModalTextField,
                let forth = forthSection as? ModalAmoutView
            else { return nil }
            
            let consumptionData = (first.paymentExtraction(),
                                   second.textFieldExtraction(),
                                   third.textFieldExtraction(),
                                   forth.amountExtraction())
            
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
                        return ("","",0,"","")
                    }
                    
                    return data
                }
                .bind(to: cashBookActiveButtonTapped)
                .disposed(by: disposeBag)
            
        case .createNewConsumption, .editConsumption:
            buttons.rx.activeButtondTapped
                .map { [weak self] _ -> ModalView.ModalConsumptionData in
                    guard let data = self?.consumptionDataExtraction() else {
                        return (false, "", "", 0)
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
        return base.allSectionIsBlank
    }
}
