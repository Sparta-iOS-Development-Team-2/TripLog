//
//  PopoverManager.swift
//  TripLog
//
//  Created by jae hoon lee on 2/10/25.
//

import UIKit

final class PopoverManager: NSObject {
    
    private let title: String
    private let subTitle: String
    private let width: Int
    private let height : Int
    
    init(title: String, subTitle: String, width: Int, height: Int) {
        self.title = title
        self.subTitle = subTitle
        self.width = width
        self.height = height
    }
    
    /// popover 사용는 메서드
    /// Parameters:
    ///  - on : 사용할 해당 뷰컨트롤러
    ///  - from : popover를 띄우기위한 기준이 될 뷰(Button)
    ///  - title : 첫번째 title
    ///  - subTitle : 두번째 title
    ///  - width : popover의 너비
    ///  - height : popover의 높이
    ///  - arrow : popover의 말풍선꼬리 방향
    ///
    ///  - Example
    ///```swift
    ///     PopoverManager.showPopover(on: self,
    ///                                from: sender,
    ///                                title: "현재의 환율은 금일 환율입니다.",
    ///                                subTitle: "휴일인 경우 마지막으로 업로드된 환율이 적용됩니다.",
    ///                                width: 170,
    ///                                height: 60,
    ///                                arrow: .down)
    ///
    /// //아이폰에서 popover기능을 사용하기 위한 메서드
    ///extension UIVIewController: UIPopoverPresentationControllerDelegate {
    ///     func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    ///      return .none
    ///     }
    /// ```
    static func showPopover(on vc: UIViewController,
                            from sourceView: UIView,
                            title: String,
                            subTitle: String,
                            width: Int,
                            height: Int,
                            arrow: UIPopoverArrowDirection) {
        
        let popoverVC = PopoverViewController()
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: width , height: height)
        
        popoverVC.titleLabel.text = title
        popoverVC.subTitleLabel.text = subTitle
        
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
            popoverController.permittedArrowDirections = arrow
            popoverController.delegate = vc as? UIPopoverPresentationControllerDelegate
        }
        
        vc.present(popoverVC, animated: true, completion: nil)
    }
}
