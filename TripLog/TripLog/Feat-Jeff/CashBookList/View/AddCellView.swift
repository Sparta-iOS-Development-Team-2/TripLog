//
//  AddCellView.swift
//  TripLog
//
//  Created by jae hoon lee on 1/22/25.
//
import UIKit
import SnapKit
import Then
import RxCocoa
import RxSwift

final class AddCellView: UIView {
    
    var disposeBag = DisposeBag()
    let addButtonTapped = PublishRelay<Void>()
    
    private let addNameLabel = UILabel().then {
        $0.text = "여행 추가하기"
        $0.textAlignment = .left
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }
    
    let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = UIColor.Light.r200
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// setupUI
    private func setupUI() {
        backgroundColor = .white
        
        [
            addButton,
            addNameLabel
        ].forEach { addSubview($0) }
        
        addNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(20)
        }
        
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(152)
        }
    }
    
    /// 셀에 그림자 추가
    private func setupShadow() {
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.lightGray.cgColor
        
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
}
