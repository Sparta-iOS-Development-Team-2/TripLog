//
//  SettingTableViewDataSource.swift
//  TripLog
//
//  Created by 장상경 on 1/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct SetTableSection {
    var header: String
    var items: [SettingTableCellModel]
}

extension SetTableSection: SectionModelType {
    typealias Item = SettingTableCellModel
    
    init(original: SetTableSection, items: [SettingTableCellModel]) {
        self = original
        self.items = items
    }
}

private extension SettingViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<SetTableSection>
    
    var sections: Observable<SetTableSection> {
        Observable.just(
            SetTableSection(
                header: "기본 설정",
                items: SettingTableCellModel.setTableModels
            )
        )
    }
    
    var dataSource: DataSource {
        let dataSource = DataSource(configureCell: { dataSource, tableView, indexPath, item in
            // 임시 데이터
            // 셀 구현 후 내용 변경
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
            
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource[index].header
            
        })
        
        return dataSource
    }
}
