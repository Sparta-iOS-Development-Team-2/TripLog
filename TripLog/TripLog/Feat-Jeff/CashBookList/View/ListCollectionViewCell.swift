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
    
    private var tripNameLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }
    
    private var noteLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    private var bugetLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    private var periodLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .body, weight: .regular)
    }
    
    private let verticalStackView = UIStackView().then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.spacing = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupShadow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// setupUI
    private func setupUI() {
        backgroundColor = .white
        
        [
            noteLabel,
            bugetLabel,
            periodLabel
        ].forEach { verticalStackView.addArrangedSubview($0) }
        
        [
            tripNameLabel,
            verticalStackView
        ].forEach { contentView.addSubview($0) }
        
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
    
    /// 셀에 그림자 추가(ContentView)
    private func setupShadow() {
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.lightGray.cgColor
        
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
   
    /// 데이터에 저장된 값으로 UI update
    func configureCell(data: ListCellData) {
        tripNameLabel.text = data.tripName
        noteLabel.text = data.note
        bugetLabel.text = "💰 \(PriceFormatModel.wonFormat(Int(data.buget)))"
        periodLabel.text = "🗓️ \(data.departure) - \(data.homecoming)"
    }
    
}
