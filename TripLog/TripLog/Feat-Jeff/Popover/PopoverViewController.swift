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
        $0.textColor = UIColor.CustomColors.Text.textPrimary
        $0.textAlignment = .left
    }
    
    var subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 10, weight: .medium)
        $0.numberOfLines = 0
        $0.minimumScaleFactor = 0.7
        $0.textColor = UIColor.CustomColors.Text.textPlaceholder
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
  
    // viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layer.shadowPath = self.view.shadowPath()
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            view.applyPopoverButtonStyle()
        }
    }
    
    /// setupUI
    private func setupUI() {
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
