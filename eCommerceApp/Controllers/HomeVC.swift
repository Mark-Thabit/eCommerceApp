//
//  HomeVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

enum Section {
    case productList
}

class HomeVC: UIViewController, Instantiatable {
    
    // MARK: - View life cycle
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - iVars
    
    // once updated collection view would animate its layout invalidation
    private var isGridLayout = true {
        didSet {
            collectionView.reloadData()
            collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>? = nil
    private var productList = Product.dummyList
    
    private lazy var layoutBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2"),
                                   style: .done,
                                   target: self,
                                   action: #selector(layoutBarButtonTapped(_:)))
        item.tintColor = .black
        return item
    }()
    
    private lazy var filterBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                                   style: .done,
                                   target: self,
                                   action: #selector(filterBarButtonTapped(_:)))
        item.tintColor = .black
        return item
    }()
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        // Fix issue regarding large title style being collapsed on first launch
        additionalSafeAreaInsets.top = 20
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        // Title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Products"
        
        // Bar buttons
        navigationItem.rightBarButtonItems = [layoutBarButton, filterBarButton]
    }
    
    private func setupCollectionView() {
        collectionView.register(cellType: ProductGridCell.self)
        collectionView.register(cellType: ProductListCell.self)
        collectionView.collectionViewLayout = generateLayout()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            
            if isGridLayout {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductGridCell.self)
                cell.titleLbl.text = "Product Name with tooo long name"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductListCell.self)
                return cell
            }
        })
        
        dataSource?.apply(snapshotForCurrentState(), animatingDifferences: true, completion: nil)
    }
    
    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, Product> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.productList])
        snapshot.appendItems(productList, toSection: .productList)
        return snapshot
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(isGridLayout ? 0.5 : 1.0),
                                                                             heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                          heightDimension: .fractionalWidth(isGridLayout ? 0.75 : 0.35)),
                                                       repeatingSubitem: item,
                                                       count: isGridLayout ? 2 : 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 5)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Target Actions
    
    @objc
    private func layoutBarButtonTapped(_ sender: UIBarButtonItem) {
        isGridLayout.toggle()
        sender.image = isGridLayout ? UIImage(systemName: "rectangle.grid.1x2") : UIImage(systemName: "square.grid.2x2")
    }
    
    @objc
    private func filterBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: - StoryboardBasedView

extension HomeVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}
