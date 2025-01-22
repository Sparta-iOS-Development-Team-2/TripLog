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

final class ModalView: UIView {
    
    fileprivate let cancelButtonTapped = PublishRelay<Void>()
    fileprivate let activeButtonTapped = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    private var state: ModalViewState
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .subtitle, weight: .bold)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let buttons: ModalButtons
    
    private let firstSection: UIView?
    private let secondSection: UIView?
    private let thirdSection: UIView?
    private let forthSection: UIView?
    
    init(state: ModalViewState) {
        self.state = state
        switch state {
        case .createNewCashBook:
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalTextField(title: "가계부 이름", subTitle: nil, placeholder: "예: 도쿄 여행 2024", keyboardType: .default)
            self.secondSection = ModalTextField(title: "여행 국가", subTitle: nil, placeholder: "예: 일본", keyboardType: .default)
            self.thirdSection = ModalTextField(title: "예산 설정", subTitle: "원(한화)", placeholder: "0", keyboardType: .numberPad)
            self.forthSection = ModalDateView()
            self.buttons = ModalButtons(buttonTitle: "생성")
            
        case .createNewbudget:
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalSegmentView()
            self.secondSection = ModalTextField(title: "지출 내용", subTitle: nil, placeholder: "예: 스시 오마카세", keyboardType: .default)
            self.thirdSection = ModalTextField(title: "카테고리", subTitle: nil, placeholder: "예: 식비", keyboardType: .default)
            self.forthSection = ModalAmoutView()
            self.buttons = ModalButtons(buttonTitle: "생성")
            
        case .editBudget(data: let data):
            self.titleLabel.text = state.modalTitle
            self.firstSection = ModalSegmentView()
            self.secondSection = ModalTextField(title: "지출 내용", subTitle: nil, placeholder: "예: 스시 오마카세", keyboardType: .default)
            self.thirdSection = ModalTextField(title: "카테고리", subTitle: nil, placeholder: "예: 식비", keyboardType: .default)
            self.forthSection = ModalAmoutView()
            self.buttons = ModalButtons(buttonTitle: "수정")
            
            if let firstSection = self.firstSection as? ModalSegmentView,
               let secondSection = self.secondSection as? ModalTextField,
               let thirdSection = self.thirdSection as? ModalTextField,
               let forthSection = self.forthSection as? ModalAmoutView
            {
                firstSection.configSegment(to: data.isCardPayment)
                secondSection.configTextField(text: data.expenseDetails)
                thirdSection.configTextField(text: data.category)
                forthSection.configtAmoutView(amout: data.amount, currency: data.carrency)
            }
        }
    
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkModalStatus() -> ModalViewState {
        return self.state
    }
    
}

private extension ModalView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bindButtons()
    }
    
    func configureSelf() {
        self.backgroundColor = .Light.base
        [titleLabel,
         firstSection!,
         secondSection!,
         thirdSection!,
         forthSection!,
         buttons].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        firstSection?.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        secondSection?.snp.makeConstraints {
            $0.top.equalTo(firstSection!.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        thirdSection?.snp.makeConstraints {
            $0.top.equalTo(secondSection!.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        forthSection?.snp.makeConstraints {
            $0.top.equalTo(thirdSection!.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(66)
        }
        
        buttons.snp.makeConstraints {
            $0.top.equalTo(forthSection!.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
    }
    
    func bindButtons() {
        buttons.rx.activeButtondTapped
            .bind(to: activeButtonTapped)
            .disposed(by: disposeBag)
        
        buttons.rx.cancelButtondTapped
            .bind(to: cancelButtonTapped)
            .disposed(by: disposeBag)
    }

}

extension Reactive where Base: ModalView {
    var activeButtonTapped: PublishRelay<Void> {
        return base.activeButtonTapped
    }
    
    var cancelButtonTapped: PublishRelay<Void> {
        return base.cancelButtonTapped
    }
}
