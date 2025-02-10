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

    private var gradientLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("🔹 layoutSubviews() 호출됨, bounds.width:", bounds.width)

        let newWidth = bounds.width * progressValue
        if newWidth != progress.frame.width { // ✅ 기존 값과 비교 후 변경 시만 업데이트
            updateProgress(progressValue)
        }
            
        layer.cornerRadius = self.bounds.height / 2
        progress.layer.cornerRadius = (self.bounds.height - 2) / 2

        // ✅ Gradient Layer 크기 업데이트
        gradientLayer?.frame = progress.bounds
    }

    private var progressValue: CGFloat = 0.0 // ✅ 초기값을 0으로 설정

    /// ✅ 프로그레스 바의 상태를 업데이트
    func updateProgress(_ value: CGFloat) {
        let progressValue = min(max(value, 0), 1) // 값이 0~1 사이를 벗어나지 않도록 제한
        self.progressValue = progressValue // ✅ 값 저장

        let newWidth = self.bounds.width * progressValue

        print("🔹 Progress bar width update: \(newWidth), View width: \(self.bounds.width)")

        // ✅ 기존 애니메이션 정리
        progress.layer.removeAllAnimations()

        // ✅ Progress Label 업데이트
        progressLabel.text = "\(Int(progressValue * 100))%"
        progress.alpha = progressValue == 0 ? 0 : 1

        // ✅ Auto Layout을 이용한 애니메이션 적용
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.progress.snp.updateConstraints {
                $0.width.equalTo(newWidth)
            }
            self.progressLabel.snp.updateConstraints {
                $0.trailing.equalTo(self.progress.snp.trailing).offset(-5) // ✅ progress 바의 끝에 위치
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            // ✅ width가 0 이상일 때만 Gradient 애니메이션 실행
            if progressValue > 0 {
                self.applyGradientAnimation()
            }
        })
    }

    // MARK: - UI Setting Method
    private func setupUI() {
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

        // ✅ 그라데이션 레이어 초기화
        setupGradientLayer()
    }

    /// ✅ 그라데이션 레이어 설정
    private func setupGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = (self.bounds.height - 2) / 2
        gradientLayer = gradient
        progress.layer.insertSublayer(gradient, at: 0)
    }

    /// ✅ 그라데이션 애니메이션 적용
    private func applyGradientAnimation() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [
            UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0).cgColor
        ]
        animation.toValue = [
            UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0).cgColor,
            UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0).cgColor
        ]
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer?.add(animation, forKey: "gradientAnimation")
    }
}
