//
//  CategoryViewController.swift
//  TripLog
//
//  Created by 장상경 on 2/15/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 카테고리 뷰 컨트롤러
final class CategoryViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private let disposeBag = DisposeBag()
    fileprivate let selectedCell = PublishRelay<String>()
    
    // MARK: - Properties
    
    private let categoryData: [String]
    
    // MARK: - UI Components
    
    private let viewTitle = UILabel().then {
        $0.text = "카테고리 선택"
        $0.font = .SCDream(size: .headline, weight: .medium)
        $0.textColor = .CustomColors.Text.textPrimary
        $0.backgroundColor = .clear
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("X", for: .normal)
        $0.setTitleColor(.CustomColors.Text.textPrimary, for: .normal)
        $0.titleLabel?.font = .SCDream(size: .display, weight: .bold)
        $0.titleLabel?.textAlignment = .right
        $0.backgroundColor = .clear
    }
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: categoryLayout).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(CategoryViewCell.self, forCellWithReuseIdentifier: CategoryViewCell.id)
    }
    
    private let categoryLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }()
    
    // MARK: - Initializer
    
    init(_ categorys: [String]) {
        categoryData = categorys
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension CategoryViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        self.modalPresentationStyle = .formSheet
        self.sheetPresentationController?.preferredCornerRadius = 12
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in 190 })]
        self.view.backgroundColor = .CustomColors.Background.background
        
        [viewTitle, closeButton, categoryCollectionView].forEach { view.addSubview($0) }
    }
    
    func setupLayout() {
        viewTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(20)
            $0.width.equalTo(100)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(viewTitle)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(viewTitle.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(80)
        }
    }
    
    func bind() {
        closeButton.rx.tap
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    
}

// MARK: - UICollectionViewDelegate Method

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = categoryCollectionView.cellForItem(at: indexPath) as? CategoryViewCell else { return }
        cell.selectedCell()
        self.selectedCell.accept(categoryData[indexPath.item])
        self.dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource Method

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.id, for: indexPath) as? CategoryViewCell
        else { return UICollectionViewCell() }
        
        cell.configureCell(title: categoryData[indexPath.item])
        
        return cell
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: CategoryViewController {
    /// 셀의 선택 이벤트를 방출하는 옵저버블
    var selectedCell: PublishRelay<String> {
        base.selectedCell
    }
}
