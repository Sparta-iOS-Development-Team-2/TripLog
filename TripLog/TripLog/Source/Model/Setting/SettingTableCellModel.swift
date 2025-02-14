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
            action: changeDarkMode
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "reviewIcon") ?? UIImage(),
            title: "리뷰 작성하기",
            extraView: nil,
            action: moveAppstore
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "mailIcon") ?? UIImage(),
            title: "문의하기",
            extraView: nil,
            action: inquiry
        ),
        
        SettingTableCellModel(
            icon: UIImage(named: "versionIcon") ?? UIImage(),
            title: "버전 1.0.0",
            extraView: nil,
            action: nil
        )
    ]
    
}

// MARK: - SettingTableCellModel Private Method

private extension SettingTableCellModel {
    
    /// 토글 스위치를 구현하는 메소드
    /// - Returns: UISwitch
    static func setupSwitch() -> UISwitch {
        let toggleSwitch = UISwitch()
        let isDarkMode = UserDefaults.standard.object(forKey: "isDarkModeEnabled") == nil ? UITraitCollection.current.userInterfaceStyle == .dark : UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        toggleSwitch.isOn = isDarkMode
        toggleSwitch.thumbTintColor = .CustomColors.Background.detailBackground
        toggleSwitch.onTintColor = .Personal.normal
                
        return toggleSwitch
    }
    
    /// 앱의 다크모드/라이트모드 상태를 변환하는 메소드
    static func changeDarkMode() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        ThemeManager.loadTheme(for: window)
    }
    
    /// 문의 기능을 Alert으로 구현한 메소드
    static func inquiry() {
        guard let view = AppHelpers.getTopViewController() else { return }
        let alert = AlertManager(
            title: "문의하기",
            message: "이메일: jeffap324@gmail.com\n구글폼 문의는 아래 버튼을 눌러주세요!",
            cancelTitle: "취소",
            activeTitle: "구글폼 문의") {
                debugPrint("구글폼 이동")
                guard let url = URL(string: "https://forms.gle/SFcJYmnhJrssd58G9") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        
        alert.showAlert(.alert)
    }
    
    /// 앱스토어 링크로 이동하는 메소드
    static func moveAppstore() {
        let url = "itms-apps://apps.apple.com/app/id6741835898"
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        debugPrint("앱스토어 이동")
    }
}
