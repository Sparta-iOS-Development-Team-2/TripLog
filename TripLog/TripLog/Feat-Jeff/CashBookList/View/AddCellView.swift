//
//  AddCellView.swift
//  TripLog
//
//  Created by jae hoon lee on 1/22/25.
//
import UIKit
import SnapKit
import Then

final class AddCellView: UIView {
    
    private let addNameLabel = UILabel().then {
        $0.text = "여행 추가하기"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.Light.r200 // 컬러 에셋에 값이 없음(938989 / ffffff)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Method

private extension AddCellView {
    
    /// setup UI
    func setupUI() {
        
        [
            addButton,
            addNameLabel
        ].forEach { addSubview($0) }
    }
    
    /// setup Constraints
    func setupConstraints() {
        addNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(20)
        }
        
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(152)
        }
    }
}
