//
//  FilterHeaderCellView.swift
//  TripLog
//
//  Created by jae hoon lee on 2/18/25.
//

import UIKit
import SnapKit
import Then

final class FilterHeaderCellView: UICollectionReusableView {
    static let id: String = "FilterHeaderCellView"
    
    private let titleLabel = UILabel().then {
        $0.font = .SCDream(size: .headline, weight: .medium)
        $0.textColor = .CustomColors.Text.textPrimary
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
