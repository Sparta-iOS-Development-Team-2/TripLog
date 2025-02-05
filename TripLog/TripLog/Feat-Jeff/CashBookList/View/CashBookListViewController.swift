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
    private let addButtonTapped = PublishRelay<Void>()
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 가계부"
        $0.font = UIFont.SCDream(size: .title, weight: .bold)
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    
    private lazy var listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: listCollectionViewLayout()
    ).then {
        $0.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        
        // 스크롤 제거
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
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
    
    //MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        bind()
    }
    
    // 추후 구현 예정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
    
            addCellView.applyBoxStyle()
            
        }
    }
    
}

//MARK: - Private Method
private extension CashBookListViewController {
    
    /// setup UI
    func setupUI() {
        
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.CustomColors.Background.background
        
        [
            titleLabel,
            listCollectionView,
            addCellView,
        ].forEach { view.addSubview($0) }
        
        // 셀 추가 버튼 그림자 설정
        addCellView.applyBoxStyle()
    }
    
    /// setup Constraints
    func setupConstraints() {
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
            $0.bottom.equalTo(safeArea.snp.bottom)
        }
    }
    
    func bind() {
        /// Input
        /// - callViewWillAppear : 추후 사용(코어데이터 fetch)
        /// - addButtonTapped : 일정 추가하기 버튼
        let input = CashBookListViewModel.Input(
            callViewWillAppear: viewWillAppearSubject.asObservable(),
            addButtonTapped: addButtonTapped
        )
        
        /// Output
        /// - updatedData : RxDataSource로 CollectionView 업데이트
        /// - showAddListModal : 새 일정 추가 모달을 사용
        /// - addCellViewHidden : 일정 추가하기 셀 뷰 fade in/out
        let output = viewModel.transform(input: input)
        
        output.updatedData
            .bind(to: listCollectionView.rx.items(dataSource: dataSource))
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
        
        // addButton 바인딩
        addCellView.addButton.rx.tap
            .bind(to: addButtonTapped)
            .disposed(by: disposeBag)
        
        // 선택된 셀 동작처리(추후 구현)
        listCollectionView.rx.modelSelected(MockCashBookModel.self)
            .subscribe(onNext: { selectedItem in
                print("\(selectedItem)")
                self.navigationController?.pushViewController(TopViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    /// CollectionView Layout
    func listCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            // 셀 뒤의 스크롤뷰 색상 변경
            configuration.backgroundColor = UIColor.CustomColors.Background.background
            
            // 셀 삭제 기능
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else {
                    return UISwipeActionsConfiguration(actions: [])
                }
                
                // dataSource에 접근(섹션목록)
                let sections = dataSource.sectionModels
                guard indexPath.section < sections.count else {
                    return nil
                }
                
                // dataSource의 선택된 section에 접근(셀)
                let section = sections[indexPath.section]
                guard indexPath.row < section.items.count else {
                    return nil
                }
                
                // dataSource의 선택된 cell에 접근
                let item = section.items[indexPath.row]
                
                // 삭제 기능
                let deletAction = UIContextualAction(style: .destructive, title: "삭제") {[weak self] _, _, completion in
                    guard let self = self else { return }
                    
                    // alert으로 삭제 여부 확인
                    let alert = AlertManager.init(title: "경고",
                                                  message: "해당 가계부를 삭제하시겠습니까?",
                                                  cancelTitle: "취소",
                                                  destructiveTitle: "삭제") {
                        CoreDataManager.shared.delete(type: CashBookEntity.self, entityID: item.identity)
                    }
                    alert.showAlert(on: self, .alert)
                    completion(true)
                }
                return UISwipeActionsConfiguration(actions: [deletAction])
            }
            
            // 셀 수정 기능
            configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                let editAction = UIContextualAction(style: .normal, title: "수정") { _, _, completion in
                    
                    guard let data = try? self.dataSource.model(at: indexPath) as? MockCashBookModel else {
                        completion(false)
                        return
                    }
                    
                    ModalViewManager.showModal(on: self, state: .editCashBook(data: data))
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
