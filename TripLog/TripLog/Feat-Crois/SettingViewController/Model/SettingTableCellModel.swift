//
//  SettingTableCellModel.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit

/// 설정탭에서 사용할 테이블뷰의 Cell Model
struct SettingTableCellModel {
    private let icon: UIImage
    private let title: String
    private let activeView: UIView?
    private let action: (() -> Void)?
    
    // 설정탭에 넣을 셀을 정의하는 프로퍼티
    static var defaultSettingModels: [SettingTableCellModel] = [
        SettingTableCellModel(
            icon: UIImage(named: "darkModeIcon") ?? UIImage(),
            title: "다크모드",
            activeView: UISwitch(),
            action: nil
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "reviewIcon") ?? UIImage(),
            title: "리뷰 작성하기",
            activeView: UISwitch(),
            action: nil
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "mailIcon") ?? UIImage(),
            title: "문의하기",
            activeView: UISwitch(),
            action: nil
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "versionIcon") ?? UIImage(),
            title: "버전 1.0.0",
            activeView: UISwitch(),
            action: nil
        )
    ]

}

