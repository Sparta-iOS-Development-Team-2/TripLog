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
        $0.text = "0%"
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
        print("🔹 layoutSubviews() 호출됨, bounds.width:", bounds.width)

        // ✅ 초기 width가 설정되지 않으면 progress 업데이트 적용되지 않음 → 강제 업데이트
        DispatchQueue.main.async {
            self.updateProgress(self.progressValue)
        }
            
        layer.cornerRadius = self.bounds.height / 2
        progress.layer.cornerRadius = (self.bounds.height - 2) / 2
    }

    private var progressValue: CGFloat = 0.0 // ✅ 현재 progress 값을 저장

    /// ✅ 프로그레스 바의 상태를 업데이트
    func updateProgress(_ value: CGFloat) {
        let progressValue = min(max(value, 0), 1) // 값이 0~1 사이를 벗어나지 않도록 제한
        self.progressValue = progressValue // ✅ 값 저장

        // ✅ 전체 너비 대비 비율 설정
        let newWidth = self.bounds.width * progressValue

        print("🔹 Progress bar width update: \(newWidth), View width: \(self.bounds.width)")
        
        // ✅ 기존 애니메이션 정리
        progress.layer.removeAllAnimations()
        progress.subviews.forEach { $0.removeFromSuperview() } // ✅ 기존 Gradient 제거


        // Progress Label 업데이트
        progressLabel.text = "\(Int(progressValue * 100))%"

        // ✅ 프로그레스가 0일 때 숨김, 0이 아닐 때 표시
        progress.alpha = progressValue == 0 ? 0 : 1

        // Auto Layout을 이용한 애니메이션 적용
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.progress.snp.updateConstraints {
                $0.width.equalTo(newWidth)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            // ✅ width가 0 이상일 때만 Gradient 애니메이션 실행
            if progressValue > 0 {
                self.progress.applyGradientAnimation(colors: [
                    UIColor(red: 0/256, green: 122/256, blue: 1.0, alpha: 1.0),
                    UIColor(red: 59/256, green: 190/256, blue: 246/256, alpha: 1.0)
                ])
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
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalTo(progress.snp.trailing).inset(5)
        }
    }
    
}
