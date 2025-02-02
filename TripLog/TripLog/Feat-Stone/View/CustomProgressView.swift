//
//  CustomProgressView.swift
//  TripLog
//
//  Created by 장상경 on 2/2/25.
//

import UIKit
import SnapKit
import Then

/// 커스텀 프로그레스 바
final class CustomProgressView: UIView {
    
    // MARK: - UI Compenents
    
    private lazy var progress = UIView().then {
        $0.backgroundColor = UIColor.Personal.normal
        $0.layer.cornerRadius = (self.bounds.height - 2) / 2
        $0.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
    }
    
    private let progressLabel = UILabel().then {
        $0.text = "0%" // 기본값 세팅
        $0.font = .SCDream(size: .caption, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .right
        $0.numberOfLines = 1
        $0.backgroundColor = .clear
    }
    
    // MARK: - Override Method
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupUI()
        progress.applyGradientAnimation(colors: [
            UIColor.Personal.normal,
            UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0)
        ])
    }
    
    /// 프로그레스바의 상태를 업데이트 하는 메소드
    /// - Parameter value: 프로그레스바의 진행도(%)
    func updateProgress(_ value: CGFloat) {
        progressLabel.text = "\(Int(value))%"
        let progressValue = self.bounds.width * (value / 100)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.progress.frame.size.width = progressValue
            self.progress.layer.layoutIfNeeded()
        }
    }
    
}

// MARK: - UI Setting Method

private extension CustomProgressView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.CustomColors.Border.plus.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = bounds.height / 2
        self.clipsToBounds = true
        [progress, progressLabel].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        progressLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalTo(progress.snp.trailing).inset(5)
        }
    }
    
}
