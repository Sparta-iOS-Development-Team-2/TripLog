//
//  UpdateTabBarItem.swift
//  TripLog
//
//  Created by jae hoon lee on 2/5/25.
//
import UIKit

extension UIButton {
    
    /// 기존의 cofig로 설정한 데이터를 새로운 config 값으로 변경하는 메서드
    /// inout을 활용해 파라미터를 직접 내부에서 UIButton.Configuration(값)을 수정
    /// 수정된 데이터로 UIButton.Configuration에 반영
    func updateConfiguration(_ update: (inout UIButton.Configuration) -> Void) {
        guard var config = self.configuration else { return }
        update(&config)
        self.configuration = config
    }
}
