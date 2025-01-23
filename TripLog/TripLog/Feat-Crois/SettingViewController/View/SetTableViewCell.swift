//
//  SetTableViewCell.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit

final class SetTableViewCell: UITableViewCell {
    
    static let id = "SetTableViewCell"
    
    private let icon = UIImageView()
    
    private let title = UILabel()
    
    private var extraView: UIView? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(model: SettingTableCellModel) {
        self.icon.image = model.icon
        self.title.text = model.title
        self.extraView = model.activeView
    }
    
}
