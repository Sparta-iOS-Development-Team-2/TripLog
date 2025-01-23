//
//  AlertManager.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit

struct AlertManager {
    let title: String
    let message: String
    let cancelTitle: String
    let activeTitle: String?
    let destructiveTitle: String?
    let completion: (() -> Void)?
    
    init(title: String,
         message: String,
         cancelTitle: String,
         activeTitle: String?,
         completion: (() -> Void)?
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.activeTitle = activeTitle
        self.completion = completion
        self.destructiveTitle = nil
    }
    
    init(title: String,
         message: String,
         cancelTitle: String,
         destructiveTitle: String?,
         completion: (() -> Void)?
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.destructiveTitle = destructiveTitle
        self.completion = completion
        self.activeTitle = nil
    }
    
    init(title: String,
         message: String,
         cancelTitle: String
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.activeTitle = nil
        self.destructiveTitle = nil
        self.completion = nil
    }
    
    func showAlert(on view: UIViewController, _ style: UIAlertController.Style) {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: self.cancelTitle, style: .cancel))
        
        if let activeTitle {
            alert.addAction(UIAlertAction(title: activeTitle, style: .default) { [weak view] _ in
                completion?()
            })
        } else if let destructiveTitle {
            alert.addAction(UIAlertAction(title: destructiveTitle, style: .destructive) { [weak view] _ in
                completion?()
            })
        }
        
        view.present(alert, animated: true)
    }
    
}


