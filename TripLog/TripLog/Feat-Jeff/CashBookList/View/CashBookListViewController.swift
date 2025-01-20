//
//  CashBookListViewController.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//
import UIKit
import Then
import SnapKit

class CashBookListViewController: UIViewController {
    
    /// titleLabel
    private let titleLabel = UILabel().then {
        $0.text = "나의 가계부"
        $0.font = UIFont.SCDream(size: .title, weight: .bold)
        $0.textAlignment = .left
        $0.backgroundColor = .white
    }
    
    /// collectionView
    private let listCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        $0.backgroundColor = .white
    }
    
    /// 임시 버튼
    private let button = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("버튼", for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        
        [
            titleLabel,
            listCollectionView,
            button
        ].forEach { view.addSubview($0) }
        
        /// titleLabel layout
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(21)
        }
        
        /// collectionView layout
        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        /// buttom layout
        button.snp.makeConstraints {
            $0.top.equalTo(listCollectionView.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeArea.snp.bottom).offset(-18)
            $0.height.equalTo(60)
        }
    }
}
