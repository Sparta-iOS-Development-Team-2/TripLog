//
//  PopoverViewController.swift
//  TripLog
//
//  Created by jae hoon lee on 2/9/25.
//

import UIKit
import SnapKit
import Then

final class PopoverViewController: UIViewController {
    
    var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.numberOfLines = 1
        $0.minimumScaleFactor = 0.7
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    var subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 10, weight: .medium)
        $0.numberOfLines = 0
        $0.minimumScaleFactor = 0.7
        $0.textColor = .gray
        $0.textAlignment = .left
    }
    
    private let verticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    /// setupUI
    private func setupUI() {
        view.backgroundColor = .white
        [
            titleLabel,
            subTitleLabel
        ].forEach { verticalStackView.addArrangedSubview($0) }
        view.addSubview(verticalStackView)
        
        verticalStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.top.equalToSuperview().offset(5)
        }
    }
    
}
