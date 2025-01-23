//
//  SetTableViewCell.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import SnapKit
import Then

/// 설정 탭의 테이블뷰 셀 UI
final class SetTableViewCell: UITableViewCell {
    
    static let id = "SetTableViewCell"
    
    // MARK: - UI Components
    
    private let icon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
    }
    
    private let title = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .medium)
        $0.numberOfLines = 1
        $0.textColor = .Dark.base
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private var extraView: UIView?
    
    // Cell Selected Action
    private(set) var action: (() -> Void)?
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용 옵션
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupReuse()
    }
    
    /// 셀의 UI를 설정하는 메소드
    /// - Parameter model: 셀 모델 데이터
    func configureCell(model: SettingTableCellModel) {
        self.icon.image = model.icon
        self.title.text = model.title
        self.extraView = model.extraView
        self.action = model.action
        
        setupUI()
    }
    
}

// MARK: - UI Setting Method

private extension SetTableViewCell {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        if self.extraView != nil {
            [icon, title, extraView!].forEach { self.addSubview($0) }
        } else {
            [icon, title].forEach { self.addSubview($0) }
        }
    }
   
    func setupLayout() {
        icon.snp.makeConstraints {
            $0.width.height.equalTo(26)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(icon.snp.trailing).offset(16)
        }
        
        extraView?.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    /// 셀 재사용시 수행할 메소드
    func setupReuse() {
        self.icon.image = nil
        self.title.text = nil
        self.extraView = nil
        self.action = nil
    }
    
}
