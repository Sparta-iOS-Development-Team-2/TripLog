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
 
    func configureCell(title: String) {
        category.text = title
    }

    func selectedCell() {
        DispatchQueue.main.async {
            self.category.font = .SCDream(size: .headline, weight: .medium)
            self.category.textColor = .white
            self.category.layer.borderColor = .none
            self.category.backgroundColor = .CustomColors.Accent.blue
        }
    }

    func resetCell() {
        DispatchQueue.main.async {
            self.category.font = .SCDream(size: .headline, weight: .medium)
            self.category.textColor = .CustomColors.Text.textSecondary
            self.category.layer.borderColor = UIColor.CustomColors.Text.textSecondary.cgColor
            self.category.backgroundColor = .CustomColors.Background.background
        }
    }

}

private extension FilterCellView {

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
