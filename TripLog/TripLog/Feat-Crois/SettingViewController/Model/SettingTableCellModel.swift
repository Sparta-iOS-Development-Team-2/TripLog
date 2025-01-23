//
//  SettingTableCellModel.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import Then

/// 설정탭에서 사용할 테이블뷰의 Cell Model
struct SettingTableCellModel {
    let icon: UIImage
    let title: String
    let extraView: UIView?
    let action: (() -> Void)?
    
    // 설정탭에 넣을 셀을 정의하는 프로퍼티
    static var defaultSettingModels: [SettingTableCellModel] = [
        SettingTableCellModel(
            icon: UIImage(named: "darkModeIcon") ?? UIImage(),
            title: "다크모드",
            extraView: setupSwitch(),
            action: toggleDarkModeSwitch
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "reviewIcon") ?? UIImage(),
            title: "리뷰 작성하기",
            extraView: nil,
            action: nil
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "mailIcon") ?? UIImage(),
            title: "문의하기",
            extraView: nil,
            action: nil
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "versionIcon") ?? UIImage(),
            title: "버전 1.0.0",
            extraView: nil,
            action: nil
        )
    ]
    
}

private extension SettingTableCellModel {
    
    static func setupSwitch() -> UISwitch {
        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = false
        toggleSwitch.onTintColor = UIColor.Personal.normal
        
        return toggleSwitch
    }
    
    static func toggleDarkModeSwitch() {
        print("toggleTest")
    }
    
}
