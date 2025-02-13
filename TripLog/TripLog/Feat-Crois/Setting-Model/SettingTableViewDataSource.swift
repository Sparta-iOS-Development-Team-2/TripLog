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

/// 설정 탭의 테이블뷰 섹션을 정의하는 모델
///
/// 추후 설정 탭이 늘어났을 때, 주석 처리된 header 옵션을 활성화 시켜 header로 구분 가능
struct SetTableSection {
//    var header: String
    var items: [SettingTableCellModel]
}

// 설정 탭의 테이블뷰 섹션을 RxDataSource로 사용할 수 있도록 확장
extension SetTableSection: SectionModelType {
    typealias Item = SettingTableCellModel
    
    init(original: SetTableSection, items: [SettingTableCellModel]) {
        self = original
        self.items = items
    }
}

// MARK: - SettingViewController DataSource

extension SettingViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<SetTableSection>
    
    // 테이블뷰 섹션 정의
    var sections: BehaviorRelay<[SetTableSection]> {
        .init(value: [
                SetTableSection(
                    // header: "기본 설정",
                    items: SettingTableCellModel.defaultSettingModels)
                ]
              )
    }
    
    // 테이블뷰 데이터소스 정의
    var dataSource: DataSource {
        let dataSource = DataSource(configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SetTableViewCell.id, for: indexPath) as? SetTableViewCell
            else { return .init() }
                    
            cell.configureCell(model: item)
            
            return cell
            
//        }, titleForHeaderInSection: { dataSource, index in
//            return dataSource[index].header
        })
        
        return dataSource
    }
}
