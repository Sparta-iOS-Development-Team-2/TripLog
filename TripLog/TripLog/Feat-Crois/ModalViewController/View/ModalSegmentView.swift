//
//  ModalSegmentView.swift
//  TripLog
//
//  Created by 장상경 on 1/21/25.
//

import UIKit
import SnapKit
import Then

/// 모달뷰에서 카드, 현금을 선택하는 세그먼트 컨트롤 공용 컴포넌츠
final class ModalSegmentView: UIView {
    
    // MARK: - UI Components
    
    private let title = UILabel().then {
        $0.text = "지불 방법"
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = UIColor.Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private let segmentView = UISegmentedControl(items: ["현금", "카드"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 세크먼트 컨트롤의 인덱스를 설정하는 메소드
    /// - Parameter isCardPayment: 지불 방법이 카드인지 확인하는 Bool 데이터
    func configureSegment(to isCardPayment: Bool) {
        self.segmentView.selectedSegmentIndex = isCardPayment ? 1 : 0
    }
    
}

// MARK: - UI Setting Method

private extension ModalSegmentView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        [title, segmentView].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        segmentView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
}
