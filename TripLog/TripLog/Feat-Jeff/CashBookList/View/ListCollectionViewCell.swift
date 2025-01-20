//
//  ListCollectionViewCell.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//

import UIKit
import SnapKit
import Then

class ListCollectionViewCell: UICollectionViewCell {
    
    // 더미데이터
    private var country: String = "일본, 미국, 하와이, 스위스, 체코"
    private var buget: Int = 26000000
    private var startDate: String = "2025.05.12"
    private var endDate: String = "2025.06.13"
    
    private let tripNameLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "겨울방학 여행 2024"
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }
    
    lazy var countryNameLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "\(country)"
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    lazy var bugetLabel = UILabel().then {
        $0.text = "💰 \(PriceFormatModel.wonFormat(buget))"
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    lazy var periodLabel = UILabel().then {
        $0.text = "🗓️ \(startDate) - \(endDate)"
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    private let verticalStackView = UIStackView().then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    private let addImageView = UIImageView().then {
        $0.image = UIImage(systemName: "plus")
        $0.tintColor = UIColor.Light.r200
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        emptySetupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 저장된 데이터가 없는 경우 UI setup
    private func emptySetupUI() {
        let safeArea = self.safeAreaLayoutGuide
        backgroundColor = .white
        
        [
            tripNameLabel,
            addImageView
        ].forEach { contentView.addSubview($0) }
        
        tripNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalTo(safeArea.snp.horizontalEdges).inset(24)
            $0.height.equalTo(20)
        }
        
        addImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(24)
        }
    }
    
    /// 데이터가 있는 경우의 UI setup
    private func setupUI() {
        let safeArea = self.safeAreaLayoutGuide
        backgroundColor = .white
        
        [
            countryNameLabel,
            bugetLabel,
            periodLabel
        ].forEach { verticalStackView.addArrangedSubview($0) }
        
        [
            tripNameLabel,
            verticalStackView
        ].forEach { contentView.addSubview($0) }
        
        tripNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalTo(safeArea.snp.horizontalEdges).inset(24)
            $0.height.equalTo(20)
        }
        
        verticalStackView.snp.makeConstraints {
            $0.top.equalTo(tripNameLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(safeArea.snp.horizontalEdges).inset(24)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}

