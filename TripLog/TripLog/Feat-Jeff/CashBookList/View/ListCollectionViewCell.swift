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
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
        $0.minimumScaleFactor = 0.7
        $0.adjustsFontSizeToFitWidth = true
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
    
    private let bugetLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let periodLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
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
    
}

//MARK: - Private Method
private extension ListCollectionViewCell {
    
    /// setup UI
    func setupUI() {
        
        backgroundColor = .clear
        // 그림자 적용
        contentView.applyBoxStyle()
        
        [
            noteLabel,
            bugetLabel,
            periodLabel
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
        
        noteLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        
        bugetLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
        
        periodLabel.snp.makeConstraints {
            $0.height.equalTo(20)
        }
    }
    
}

//MARK: - Method
extension ListCollectionViewCell {
    
    /// 데이터에 저장된 값으로 UI update
    func configureCell(data: ListCellData) {
        tripNameLabel.text = data.tripName
        noteLabel.text = data.note
        bugetLabel.text = "💰 \(NumberFormatter.wonFormat(Int(data.buget)))"
        periodLabel.text = "🗓️ \(data.departure) - \(data.homecoming)"
    }
    
}
