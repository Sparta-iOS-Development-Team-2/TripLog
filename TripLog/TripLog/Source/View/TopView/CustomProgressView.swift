import UIKit
import SnapKit
import Then

/// 커스텀 프로그레스 바
final class CustomProgressView: UIView {
    
    // MARK: - UI Components
    private lazy var progress = UIView().then {
        $0.backgroundColor = .clear // ✅ 배경을 투명하게 설정 (그라데이션 적용을 위해)
    }
    
    private let progressLabel = UILabel().then {
        $0.text = "0%"
        $0.font = .SCDream(size: .caption, weight: .regular)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.backgroundColor = .clear
    }
    
    private let progressGradientColors: [UIColor] = [
        UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0),
        UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0)
    ]
    
    private var gradientLayer: CAGradientLayer?
    private var progressValue: CGFloat = 0.0 // ✅ 초기값을 0으로 설정
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newWidth = bounds.width * progressValue
        if newWidth != progress.frame.width { // ✅ 기존 값과 비교 후 변경 시만 업데이트
            updateProgress(progressValue)
        }
        
        layer.cornerRadius = self.bounds.height / 2
        progress.layer.cornerRadius = (self.bounds.height - 2) / 2
        
        // ✅ Gradient Layer 크기 업데이트
        gradientLayer?.frame = progress.bounds
        progress.applyGradient(colors: progressGradientColors)
    }
    
    /// ✅ 프로그레스 바의 상태를 업데이트
    func updateProgress(_ value: CGFloat) {
        let progressValue = min(max(value, 0), 1) // 값이 0~1 사이를 벗어나지 않도록 제한
        self.progressValue = progressValue // ✅ 값 저장
        
        let newWidth = progressValue < 0.07 ? self.bounds.width * 0.07 : self.bounds.width * progressValue
                
        // ✅ Progress Label 업데이트
        progressLabel.text = "\(Int(progressValue * 100))%"
        progress.alpha = progressValue == 0 ? 0 : 1
        
        // ✅ Auto Layout을 이용한 애니메이션 적용
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.progress.snp.updateConstraints {
                $0.width.equalTo(newWidth)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            // ✅ width가 0 이상일 때만 Gradient 애니메이션 실행
            if progressValue > 0 {
                self.applyGradientAnimation()
            }
        })
    }
}

// MARK: - UI Setting Method

private extension CustomProgressView {
    func setupUI() {
        self.backgroundColor = .clear
        self.applyTextFieldStroke()
        self.clipsToBounds = true
        
        [progress, progressLabel].forEach { addSubview($0) }
        
        progress.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(1)
            $0.width.equalTo(0) // ✅ 초기 너비 0
        }
        
        progressLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(progress.snp.trailing).offset(-5) // ✅ progress 끝에 고정
        }
    }
    
    /// ✅ 그라데이션 애니메이션 적용
    func applyGradientAnimation() {
        progress.applyGradientAnimation(colors: progressGradientColors) // ✅ UIView의 applyGradientAnimation() 사용
    }
}
