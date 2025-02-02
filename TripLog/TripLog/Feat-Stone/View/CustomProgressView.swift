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
        $0.frame = CGRect(x: 0, y: 0, width: 0, height: 16)
    }
    
    private let progressLabel = UILabel().then {
        $0.text = "0%" // 기본값 세팅
        $0.font = .SCDream(size: .caption, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .right
        $0.numberOfLines = 1
        $0.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureSubViews()
    }
    
    // 앱의 라이트모드/다크모드가 변경 되었을 때 이를 감지하여 CALayer의 컬러를 재정의 해주는 메소드
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.applyTextFieldStroke()
        }
    }
    
    /// 프로그레스바의 상태를 업데이트 하는 메소드
    /// - Parameter value: 프로그레스바의 진행도(%)
    func updateProgress(_ value: CGFloat) {
        progressLabel.text = "\(Int(value * 100))%"
        let progressValue = (UIScreen.main.bounds.width - 32) * value
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
        self.applyTextFieldStroke()
        self.clipsToBounds = true
        [progress, progressLabel].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        progressLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalTo(progress.snp.trailing).inset(5)
        }
    }
    
    func configureSubViews() {
        layer.cornerRadius = self.bounds.height / 2
        progress.layer.cornerRadius = self.bounds.height / 2
        progress.applyGradientAnimation(colors: [
            UIColor.Personal.normal,
            UIColor(red: 98/256, green: 208/256, blue: 1.0, alpha: 1.0)
        ])
    }
}
