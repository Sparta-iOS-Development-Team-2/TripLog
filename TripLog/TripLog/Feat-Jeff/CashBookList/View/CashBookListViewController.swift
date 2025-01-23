//
//  CashBookListViewController.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//
import UIKit
import SnapKit
import Then
import RxDataSources
import RxSwift

final class CashBookListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = CashBookListViewModel()
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 가계부"
        $0.font = UIFont.SCDream(size: .title, weight: .bold)
        $0.textAlignment = .left
        $0.backgroundColor = .white
    }
    
    lazy var listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: listCollectionViewLayout()
    ).then {
        $0.backgroundColor = .white
    }
    
    /// 임시 버튼
    private let testButton = UIButton().then {
        $0.backgroundColor = .lightGray
        $0.setTitle("버튼", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
       
        
        listCollectionView.register(EmptyListCollectionViewCell.self, forCellWithReuseIdentifier: EmptyListCollectionViewCell.id)
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    /// Rx를 이용한 dataSource구현(타입에는 SectionModelType인 SectionOfListCellData으로 정의)
    /// RxCollectionViewSectionedAnimatedDataSource -> // 변화....
    private let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfListCellData>(
        configureCell: {dataSource, collectionView, indexPath, item in
            
            let sectionType = dataSource.sectionModels[indexPath.section].state
            switch sectionType {
                // 첫 번째 섹션: emptyState 셀
            case .emptyState:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmptyListCollectionViewCell.id,
                    for: indexPath
                ) as? EmptyListCollectionViewCell else {
                    fatalError("셀을 불러오지 못함")
                }
                return cell
                
                // 두 번째 섹션: existState 셀
            case .existState:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ListCollectionViewCell.id,
                    for: indexPath
                ) as? ListCollectionViewCell else {
                    fatalError("셀을 불러오지 못함")
                }
                cell.configureCell(data: item)
                return cell
            }
        }
    )
    
    func bind() {
        let input = CashBookListViewModel.Input(
            callViewWillAppear: viewWillAppearSubject.asObservable(),
            buttonTapped: testButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.updatedData
            .drive(listCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    /// ViewController 레이아웃
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        navigationController?.navigationBar.isHidden = true
        
        [
            titleLabel,
            listCollectionView,
            testButton
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(21)
        }
        
        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        testButton.snp.makeConstraints {
            $0.top.equalTo(listCollectionView.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeArea.snp.bottom).offset(-18)
            $0.height.equalTo(60)
        }
    }
    
    
    /// CollectionView Layout(UICollectionLayoutListConfiguration)
    private func listCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            switch sectionIndex {
            case 0:
                configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
                    let deletAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
                        print("삭제")
                        completion(true)
                    }
                    return UISwipeActionsConfiguration(actions: [deletAction])
                }
                configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                    let editAction = UIContextualAction(style: .normal, title: "수정") { _, _, completion in
                        print("수정")
                        completion(true)
                    }
                    return UISwipeActionsConfiguration(actions: [editAction])
                }
                
            case 1:
                configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
                    let deletAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
                        print("삭제")
                        completion(true)
                    }
                    return UISwipeActionsConfiguration(actions: [deletAction])
                }
                configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                    let editAction = UIContextualAction(style: .normal, title: "수정") { _, _, completion in
                        print("수정")
                        completion(true)
                    }
                    return UISwipeActionsConfiguration(actions: [editAction])
                }
            default:
                break
            }
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 10, trailing: 2)
            return section
        }
        
        return layout
    }
    
    /// CollectionView Composition Layout (compositional.list 넣어서 스와이프 부드러운 모션)
//    private func listCollectionViewLayout() -> UICollectionViewLayout{
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .fractionalHeight(1.0))
//        
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(153))
//        
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 10, trailing: 2)
//        
//        return UICollectionViewCompositionalLayout(section: section)
//    }
}

/*
 var leadingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider?
 셀의 앞쪽 가장자리를 스와이프할 때 표시할 작업 세트를 제공하는 클로저입니다.
 var trailingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider?
 */

/// 어떻게 해야 첫번째 셀을 지울 수 있을지에 대해서 고민
/// 가로 스크롤할 때 기능 구현
/// 버튼 연결
/// pr올리는게 목표
