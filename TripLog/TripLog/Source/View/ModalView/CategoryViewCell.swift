//
//  CategoryViewCell.swift
//  TripLog
//
//  Created by 장상경 on 2/15/25.
//

import UIKit
import SnapKit
import Then

final class CategoryViewCell: UICollectionViewCell {
    
    static let id: String = "CategoryViewCell"
        
    // MARK: - UI Components
    
    private let category = UILabel().then {
        $0.textColor = .CustomColors.Text.textSecondary
        $0.font = .SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.backgroundColor = .CustomColors.Background.background
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.CustomColors.Text.textSecondary.cgColor
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀의 설정을 하는 메소드
    /// - Parameter title: 버튼의 타이틀
    func configureCell(title: String) {
        category.text = title
    }
    
    func selectedCell() {
        category.font = .SCDream(size: .headline, weight: .bold)
        category.textColor = .white
        category.layer.borderColor = .none
        category.backgroundColor = .CustomColors.Accent.blue
    }
    
}

// MARK: - UI Setting Method

private extension CategoryViewCell {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.addSubview(category)
    }
    
    func setupLayout() {
        category.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(32)
        }
    }
    
}
