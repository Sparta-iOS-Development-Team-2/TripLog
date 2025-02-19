//
//  FilterViewController.swift
//  TripLog
//
//  Created by jae hoon lee on 2/17/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

enum SectionLayoutKind: Int, CaseIterable {
    case paymentWays, categories
    
    var sectionsItems: Int {
        switch self {
        case .paymentWays:
            return 3
        case .categories:
            return 9
        }
    }
}

class FilterViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = FilterViewModel()
    
    private let sendPayment = PublishRelay<String>()
    private let sendCategory = PublishRelay<String>()
    
    private let paymentWaySection: String = "지출 방법"
    private let paymentWay: [String] = ["전체", "현금", "카드"]
    private let categorySetction: String = "카테고리"
    private let category: [String] = ["전체",
                                      "식비", "교통", "숙소", "쇼핑",
                                      "의료", "통신", "여가/취미", "기타"]
    
    private var selectedPayment: String
    private var selectedCategory: String
    private var selectedCellIndexPaths: [Int: IndexPath] = [:]
    
    private let filterViewTitle = UILabel().then {
        $0.text = "필터 선택"
        $0.font = .SCDream(size: .subtitle, weight: .bold)
        $0.textColor = .CustomColors.Text.textPrimary
        $0.backgroundColor = .clear
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("X", for: .normal)
        $0.setTitleColor(.CustomColors.Text.textPrimary, for: .normal)
        $0.titleLabel?.font = .SCDream(size: .display, weight: .bold)
        $0.backgroundColor = .clear
    }
    
    private let topHorizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: filterCollectionViewLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(FilterCellView.self, forCellWithReuseIdentifier: FilterCellView.id)
        $0.register(FilterHeaderCellView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: FilterHeaderCellView.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureSelf()
        bind()
    }
    
    // 필터 초기 데이터는 "전체"로 고정
    init(_ selectedPayment: String = "전체", _ selectedCategory: String = "전체") {
        self.selectedPayment = selectedPayment
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
        
        if let paymentIndex = paymentWay.firstIndex(of: selectedPayment) {
            selectedCellIndexPaths[0] = IndexPath(item: paymentIndex, section: 0)
        }
        if let categoryIndex = category.firstIndex(of: selectedCategory) {
            selectedCellIndexPaths[1] = IndexPath(item: categoryIndex, section: 1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
private extension FilterViewController {
    
    /// setupUI
    func setupUI() {
        view.backgroundColor = UIColor.CustomColors.Background.background
        [ filterViewTitle, closeButton ].forEach { topHorizontalStackView.addArrangedSubview($0) }
        [ topHorizontalStackView, collectionView ].forEach {view.addSubview($0) }
        
        topHorizontalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.equalTo(20)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topHorizontalStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    /// 
    func bind() {
        let input = FilterViewModel.Input(selectedPayment: sendPayment,
                                          selectedCategory: sendCategory)
        
        let output = viewModel.transform(input: input)
        
        output.dismissTrigger
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
    // 모달 설정
    func configureSelf() {
        self.modalPresentationStyle = .formSheet
        self.sheetPresentationController?.preferredCornerRadius = 12
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in 330 })]
        self.sheetPresentationController?.prefersGrabberVisible = true
    }
    
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 섹션의 갯수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionLayoutKind.allCases.count
    }
    
    // 셀을 선택 했을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else { return }
        
        // 이전 셀 데이터
        if let previousIndexPath = selectedCellIndexPaths[indexPath.section],
           let previousCell = collectionView.cellForItem(at: previousIndexPath) as? FilterCellView {
            previousCell.resetCell()
        }
        
        selectedCellIndexPaths[indexPath.section] = indexPath
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? FilterCellView {
            selectedCell.selectedCell()
        }
        
        switch sectionKind {
        case .paymentWays:
            selectedPayment = paymentWay[indexPath.item]
            sendPayment.accept(paymentWay[indexPath.item])
            print(selectedPayment)
        case .categories:
            selectedCategory = category[indexPath.item]
            sendCategory.accept(category[indexPath.item])
            print(selectedCategory)
        }
        
        print("\(selectedPayment), \(selectedCategory)")
    }
    
    func closeFilter() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 셀 구현
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCellView.id, for: indexPath) as? FilterCellView
        else { return UICollectionViewCell() }
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else { return cell }
        
        if let selectedIndexPath = selectedCellIndexPaths[indexPath.section],
           selectedIndexPath == indexPath {
            cell.selectedCell()
        } else {
            cell.resetCell()
        }
        
        let title: String
        
        switch sectionKind {
        case .paymentWays:
            title = paymentWay[indexPath.item]
        case .categories:
            title = category[indexPath.item]
        }
        
        cell.configureCell(title: title)
        return cell
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: FilterHeaderCellView.id,
            for: indexPath
        ) as? FilterHeaderCellView else {
            return UICollectionReusableView()
        }
        
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else {
            return headerView
        }
        
        let headerTitle: String
        switch sectionKind {
        case .paymentWays:
            headerTitle = paymentWaySection
        case .categories:
            headerTitle = categorySetction
        }
        
        headerView.configure(with: headerTitle)
        return headerView
    }
    
    
    // 섹션이 가지고 있는 아이템의 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = SectionLayoutKind(rawValue: section) else { return 0 }
        
        switch sectionKind {
        case .paymentWays:
            return paymentWay.count
        case .categories:
            return category.count
        }
    }
    
}

extension FilterViewController {
    // collectionView 레이아웃
    func filterCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            
            let section: NSCollectionLayoutSection?
            
            switch sectionKind {
            case .paymentWays:
                section = self.setPaymentWayLayout(
                    groupItemCount: SectionLayoutKind.categories.rawValue,
                    groupCount: 1)
            case .categories:
                section = self.setCategoryLayout()
            }
            
            if let section = section {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                section.boundarySupplementaryItems = [header]
                return section
            }
            return nil
        }
        
    }
    
    // 지출 방법 레이아웃
    func setPaymentWayLayout(groupItemCount: Int, groupCount: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize( widthDimension: .fractionalWidth(0.25),
                                               heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(32))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        return section
    }
    
    // 카테고리 레이아웃
    func setCategoryLayout() -> NSCollectionLayoutSection {
        var groups: [NSCollectionLayoutGroup] = []
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                              heightDimension: .fractionalHeight(1.0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(32))
        
        let firstItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let firstLowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: firstItem, count: 1)
        groups.append(firstLowGroup)
        
        let secondItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let secondLowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [secondItem])
        groups.append(secondLowGroup)
        
        let thirdItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let thirdLowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [thirdItem])
        groups.append(thirdLowGroup)
        
        let categoryGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        let categoryGroup = NSCollectionLayoutGroup.vertical(layoutSize: categoryGroupSize, subitems: groups)
        categoryGroup.interItemSpacing = .fixed(15.71)
        
        let section = NSCollectionLayoutSection(group: categoryGroup)
        section.interGroupSpacing = 100
        section.orthogonalScrollingBehavior = .none
        return section
    }
    
    
}
