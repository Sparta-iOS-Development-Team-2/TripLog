//
//  FilterCellView.swift
//  TripLog
//
//  Created by jae hoon lee on 2/17/25.
//

import UIKit
import SnapKit
import Then

final class FilterCellView: UICollectionViewCell {
    static let id: String = "FilterCellView"

    // 카테고리 버튼(셀)
    private let category = UILabel().then {
        $0.font = .SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.backgroundColor = .CustomColors.Background.background
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.CustomColors.Text.textSecondary.cgColor
        $0.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    /// 셀 구성
    /// - parameter : 모델에 있는 데이터로 셀 구현
    func configureCell(title: String) {
        category.text = title
    }
    
    /// 선택된 셀의 강조
    func selectedCell() {
        DispatchQueue.main.async {
            self.category.font = .SCDream(size: .headline, weight: .medium)
            self.category.textColor = .white
            self.category.layer.borderColor = .none
            self.category.layer.borderWidth = 0
            self.category.backgroundColor = .CustomColors.Accent.blue
        }
    }

    /// 선택이 해제된 셀로 변경
    func resetCell() {
        DispatchQueue.main.async {
            self.category.font = .SCDream(size: .headline, weight: .medium)
            self.category.textColor = .CustomColors.Text.textSecondary
            self.category.layer.borderColor = UIColor.CustomColors.Text.textSecondary.cgColor
            self.category.layer.borderWidth = 1
            self.category.backgroundColor = .CustomColors.Background.background
        }
    }

}

private extension FilterCellView {

    /// setupUI 설정
    func setupUI() {
        configureSelf()
        setupLayout()
    }

    /// configureSelf 설정
    func configureSelf() {
        self.backgroundColor = .clear
        self.addSubview(category)
    }

    /// setupLayout 설정
    func setupLayout() {
        category.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(75)
            $0.height.equalTo(32)
        }
    }

}
