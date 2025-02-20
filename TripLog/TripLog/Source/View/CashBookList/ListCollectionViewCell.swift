//
//  ListCollectionViewCell.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//
import UIKit
import SnapKit
import Then

final class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCollectionViewCell"
    
    private let tripNameLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .bold)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.minimumScaleFactor = 0.7
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let noteImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.image = .cbPin
    }
    
    private let noteLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.minimumScaleFactor = 0.5
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let noteStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
    }
    
    private let budgetImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.image = .cbCoin
    }
    
    private let budgetLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let budgetStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
    }
    
    private let periodImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.image = .cbAriplan
    }
    
    private let periodLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let periodStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 5
    }
    
    private let verticalStackView = UIStackView().then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            contentView.applyBoxStyle()
        }
    }
    
    /// 셀이 재사용될 때 모든 상태를 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetCell()
    }
    
}

//MARK: - Private Method
private extension ListCollectionViewCell {
    
    /// setup UI
    func setupUI() {
        
        backgroundColor = .clear
        // 그림자 적용
        contentView.applyBoxStyle()
        
        [
            noteImageView,
            noteLabel
        ].forEach { noteStackView.addArrangedSubview($0) }
        
        [
            budgetImageView,
            budgetLabel
        ].forEach { budgetStackView.addArrangedSubview($0) }
        
        [
            periodImageView,
            periodLabel
        ].forEach { periodStackView.addArrangedSubview($0) }
        
        [
            noteStackView,
            budgetStackView,
            periodStackView
        ].forEach { verticalStackView.addArrangedSubview($0) }
        
        [
            tripNameLabel,
            verticalStackView
        ].forEach { contentView.addSubview($0) }
    }
    
    /// setup Constraints
    func setupConstraints() {
        tripNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalTo(contentView.snp.horizontalEdges).inset(24)
            $0.height.equalTo(20)
        }
        
        verticalStackView.snp.makeConstraints {
            $0.top.equalTo(tripNameLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        noteImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        budgetImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        periodImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }

    }
    
    /// 셀 재사용 시 리셋 메서드
    func resetCell() {
        tripNameLabel.text = nil
        noteLabel.text = nil
        budgetLabel.text = nil
        periodLabel.text = nil
    }
    
}

//MARK: - Method
extension ListCollectionViewCell {
    
    /// 데이터에 저장된 값으로 UI update
    func configureCell(data: CashBookModel) {
        tripNameLabel.text = data.tripName
        noteLabel.text = data.note
        budgetLabel.text = "\(NumberFormatter.wonFormat(Int(data.budget)))"
        periodLabel.text = "\(Formatter.dateFormat(data.departure)) - \(Formatter.dateFormat(data.homecoming))"
    }
    
}
