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
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 가계부"
        $0.font = UIFont.SCDream(size: .title, weight: .bold)
        $0.textAlignment = .left
        $0.backgroundColor = .white
    }
    
    private lazy var listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: listCollectionViewLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
    }
    
    // 임시 버튼
    private let testButton = UIButton().then {
        $0.backgroundColor = .lightGray
        $0.setTitle("버튼", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    // RxdataSource(animated)
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<SectionOfListCellData>
    private let dataSource: DataSource = {
        let animationConfiguration = AnimationConfiguration(
            insertAnimation: .bottom,
            reloadAnimation: .none,
            deleteAnimation: .automatic
        )
        let dataSource = DataSource(
            animationConfiguration: animationConfiguration,
            configureCell: { dataSource, collectionView, indexPath, item -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ListCollectionViewCell.id,
                    for: indexPath
                ) as? ListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configureCell(data: item) 
                return cell
            }
        )
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        bind()
    }
    
    // 추후 구현 예정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
}

//MARK: - Method

extension CashBookListViewController {
    
    /// setup UI
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        
        [
            titleLabel,
            listCollectionView,
            addCellView,
            testButton
        ].forEach { view.addSubview($0) }
    }
    
    /// setup Constraints
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
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
    
    private func bind() {
        /// Input
        /// - callViewWillAppear : 추후 사용(코어데이터 fetch)
        /// - testButtonTapped : 임시 데이터 추가 버튼(삭제 예정)
        /// - addButtonTapped : 일정 추가하기 버튼
        let input = CashBookListViewModel.Input(
            callViewWillAppear: viewWillAppearSubject.asObservable(),
            testButtonTapped: testButtonTapped,
            addButtonTapped: addButtonTapped
        )
        
        /// Output
        /// - updatedData : RxDataSource로 CollectionView 업데이트
        /// - showAddListModal : 새 일정 추가 모달을 사용
        /// - addCellViewHidden : 일정 추가하기 뷰 fade in/out
        let output = viewModel.transform(input: input)
        
        output.updatedData
            .drive(listCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showAddListModal
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit(onNext: { owner, _ in
                ModalViewManager.showModal(on: owner, state: .createNewCashBook)
            })
            .disposed(by: disposeBag)
        
        output.addCellViewHidden
            .drive(onNext: { [weak self] alpha in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.addCellView.alpha = alpha
                }
            }).disposed(by: disposeBag)
        
        // testButton 바인딩
        testButton.rx.tap
            .bind(to: testButtonTapped)
            .disposed(by: disposeBag)
        
        // addButton 바인딩
        addCellView.addButton.rx.tap
            .bind(to: addButtonTapped)
            .disposed(by: disposeBag)
        
        // 선택된 셀 동작처리(추후 구현)
        listCollectionView.rx.modelSelected(ListCellData.self)
            .subscribe(onNext: { selectedItem in
                print("\(selectedItem)")
            })
            .disposed(by: disposeBag)
    }
    
    /// CollectionView Layout
    private func listCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            // 셀 삭제 기능
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else {
                    return UISwipeActionsConfiguration(actions: [])
                }
                
                let item = self.viewModel.items[indexPath.row]
                
                let deletAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
                    self.viewModel.deleteItem(with: item.identity)
                    completion(true) // 추후 기능 구현
                }
                return UISwipeActionsConfiguration(actions: [deletAction])
            }
            
            // 셀 수정 기능
            configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                let editAction = UIContextualAction(style: .normal, title: "수정") { _, _, completion in
                    completion(true) // 추후 기능 구현
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