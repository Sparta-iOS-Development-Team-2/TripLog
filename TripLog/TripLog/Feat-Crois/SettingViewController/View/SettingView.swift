//
//  SettingView.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import SnapKit
import Then

/// 설정 탭의 설정 뷰
final class SettingView: UIView {
        
    // MARK: - UI Components
    
    private let title = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.SCDream(size: .title, weight: .bold)
        $0.textColor = .Dark.base
        $0.numberOfLines = 1
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private(set) var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.rowHeight = 58
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(SetTableViewCell.self, forCellReuseIdentifier: SetTableViewCell.id)
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension SettingView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        self.backgroundColor = .Light.base
        [title, tableView].forEach { self.addSubview($0) }
    }
    
    func setupLayout() {
        title.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(12)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(26)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
