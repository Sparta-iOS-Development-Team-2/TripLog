import UIKit
import SnapKit
import Then

/// 커스텀 프로그레스 바
final class CustomProgressView: UIView {

    // MARK: - UI Components

    private lazy var progress = UIView().then {
        $0.backgroundColor = UIColor.Personal.normal
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.applyTextFieldStroke()
        }
    }

    /// ✅ **프로그레스 바의 상태를 업데이트**
    /// - Parameter value: 프로그레스 바의 진행도 (%)
    func updateProgress(_ value: CGFloat) {
        let progressValue = min(max(value, 0), 1) // 값이 0~1 사이를 벗어나지 않도록 제한
        let newWidth = (self.bounds.width - 34) * progressValue
        
        // ✅ Progress Label 업데이트
        progressLabel.text = "\(Int(progressValue * 100))%"

        // ✅ Auto Layout을 이용한 애니메이션 적용
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.progress.snp.updateConstraints {
                $0.width.equalTo(newWidth)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            // ✅ Gradient 애니메이션 다시 적용
            self.progress.applyGradientAnimation(colors: [
                UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0),
                UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0)
            ])
        })
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
        progress.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(1)
            $0.width.equalTo(0) // 초기 너비 0
        }

        progressLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalTo(progress.snp.trailing).inset(5)
        }
    }

    func configureSubViews() {
        layer.cornerRadius = self.bounds.height / 2
        progress.layer.cornerRadius = (self.bounds.height - 2) / 2
    }
}
