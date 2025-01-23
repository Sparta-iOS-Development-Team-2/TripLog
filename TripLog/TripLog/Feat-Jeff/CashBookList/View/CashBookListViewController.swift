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
import RxCocoa
import RxSwift

final class CashBookListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let addCellView = AddCellView()
    private let viewModel = CashBookListViewModel()
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let testButtonTapped = PublishRelay<Void>()
    private let addButtonTapped = PublishRelay<Void>()
    
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<SectionOfListCellData>
    
    let dataSource: DataSource = {
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ListCollectionViewCell.id,
                    for: indexPath
                ) as? ListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configureCell(data: item)
                return cell })
        dataSource.canMoveItemAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        return dataSource
    }()
    
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
        
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        
        setupUI()
        setDataSource()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    /// Rx를 이용한 dataSource구현(타입에는 SectionModelType인 SectionOfListCellData으로 정의)
    /// RxCollectionViewSectionedAnimatedDataSource -> // 변화....
    private func setDataSource() {
        
    }
    
    func bind() {
        let input = CashBookListViewModel.Input(
            callViewWillAppear: viewWillAppearSubject.asObservable(),
            testButtonTapped: testButtonTapped,
            addButtonTapped: addButtonTapped
        )
        
        testButton.rx.tap
            .bind(to: testButtonTapped)
            .disposed(by: disposeBag)
        
        addCellView.addButton.rx.tap
            .bind(to: addButtonTapped)
            .disposed(by: disposeBag)
        
        listCollectionView.rx.modelSelected(ListCellData.self)
            .subscribe(onNext: { selectedItem in
                print("\(selectedItem)")
            })
            .disposed(by: disposeBag)
        
        
        let output = viewModel.transform(input: input)
        
        output.updatedData
            .drive(listCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showAddListModal
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: {
                print("호출")
                ModalViewManager.showModal(on: self, state: .createNewCashBook)
            })
            .disposed(by: disposeBag)
        
        // MARK: - 히든 말고 알파값으로 조정해서 자연스러운
        output.addCellViewHidden
            .drive(onNext: { [weak self] isHidden in
                self?.addCellView.isHidden = isHidden
                self?.addCellView.alpha
            }).disposed(by: disposeBag)
    }
    
    /// ViewController 레이아웃
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        navigationController?.navigationBar.isHidden = true
        
        [
            titleLabel,
            listCollectionView,
            addCellView,
            testButton
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        addCellView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(152)
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
            
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else {
                    return UISwipeActionsConfiguration(actions: [])
                }
                
                let item = self.viewModel.items[indexPath.row]
                
                let deletAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
                    print("삭제")
                    self.viewModel.deleteItem(with: item.identity)
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
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 10, trailing: 2)
            return section
        }
        return layout
    }
}

/// 어떻게 해야 첫번째 셀을 지울 수 있을지에 대해서 고민 V
/// 가로 스크롤할 때 기능 구현(V)
/// 버튼 연결
/// pr올리는게 목표
