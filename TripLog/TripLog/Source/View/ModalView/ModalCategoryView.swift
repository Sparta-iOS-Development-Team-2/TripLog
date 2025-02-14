//
//  ModalCategoryView.swift
//  TripLog
//
//  Created by 장상경 on 2/14/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 모달에서 텍스트 입력을 받을 텍스트 필드 공용 컴포넌츠
final class ModalCategoryView: UIView {
    
    // MARK: - Rx Properties
    
    fileprivate var categoryIsEmpty = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let title = UILabel().then {
        $0.text = "카테고리"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    fileprivate let categoryButton = UIButton().then {
        $0.applyTextFieldStyle()
    }
    
    private let buttonIcon = UIImageView().then {
        $0.image = UIImage(systemName: "arrowtriangle.down.fill")
        $0.tintColor = .CustomColors.Accent.blue
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
    }
    
    private let categoryPlaceholderText = UILabel().then {
        $0.text = "예: 식비"
        $0.textAlignment = .left
        $0.font = .SCDream(size: .body, weight: .light)
        $0.textColor = .CustomColors.Text.textPlaceholder
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    /// 텍스트필드 기본 생성자
    /// - Parameters:
    ///   - title: 텍스트필드 대제목
    ///   - subTitle: 텍스트필드 부제목(없을 수 있음)
    ///   - placeholder: placeholder 텍스트
    ///   - keyboardType: 키보드 타입 지정
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
            self.categoryButton.applyTextFieldStroke()
        }
    }
    
    /// 텍스트필드를 세팅하는 메소드
    /// - Parameter text: 텍스트필드에 넣을 텍스트
    func configurePlaceholderText(text: String) {
        self.categoryIsEmpty.accept(false)
        categoryPlaceholderText.text = text
        categoryPlaceholderText.textAlignment = .center
        categoryPlaceholderText.font = .SCDream(size: .body, weight: .regular)
        categoryPlaceholderText.textColor = .white
        categoryPlaceholderText.backgroundColor = UIColor(red: .random(in: 0...0.6), green: .random(in: 0...0.6), blue: .random(in: 0...0.6), alpha: 1.0)
        categoryPlaceholderText.layer.cornerRadius = 13
    }
    
    /// 텍스트필드의 데이터를 추출하는 메소드
    /// - Returns: 텍스트필드의 텍스트
    func categoryExtraction() -> String {
        guard let text = categoryPlaceholderText.text else { return "" }
        return text
    }
    
}

// MARK: - UI Setting Method

private extension ModalCategoryView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
//        categoryIsEmpty.accept(true) // 초기값 세팅
        bind()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, categoryButton, buttonIcon, categoryPlaceholderText].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        buttonIcon.snp.makeConstraints {
            $0.centerY.equalTo(categoryButton)
            $0.trailing.equalTo(categoryButton).inset(12)
            $0.width.height.equalTo(12)
        }
        
        categoryPlaceholderText.snp.makeConstraints {
            $0.centerY.equalTo(categoryButton)
            $0.leading.equalTo(categoryButton).offset(12)
            $0.width.equalTo(64)
            $0.height.equalTo(26)
        }
    }
    
    func bind() {
        categoryButton.rx.tap
            .flatMap {
                let model: [String] = [
                    "식비", "교통", "숙소", "쇼핑",
                    "의료", "통신", "여가/취미", "기타"
                ]
                
                return ModalViewManager.showCategoryModal(model)
            }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, category in
                owner.configurePlaceholderText(text: category)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: ModalCategoryView {
    /// 카테고리가 비어있는지 여부를 확인하여 이벤트를 방출하는 옵저버블
    var categoryIsEmpty: BehaviorRelay<Bool> {
        return base.categoryIsEmpty
    }
}
