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
            collectionView.setCollectionViewLayout(generateLayout(), animated: true) { _ in
                // Enable it again after animations is done
                self.layoutBarButton.isEnabled = true
            }
        }
    }
    
    private var productList: [Product] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>? = nil
    
    private var inFilterMode = false
    private var filteredList: [Product] = []
    
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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .black
        return searchController
    }()
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchProductList()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
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
                cell.product = productList[indexPath.row]
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ProductListCell.self)
                cell.product = productList[indexPath.row]
                return cell
            }
        })
        
        dataSource?.apply(snapshotForCurrentState(), animatingDifferences: true, completion: nil)
    }
    
    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, Product> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.productList])
        snapshot.appendItems(inFilterMode ? filteredList : productList, toSection: .productList)
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
    
    private func fetchProductList() {
        let fetchOperation = RequestOperation(request: ServerAPI.fetchProductList, decodeType: [Product].self)
        fetchOperation.successHandler = { [weak self] list in
            guard let self else { return }
            
            self.productList = list
            self.updateCollectionData()
            self.navigationItem.searchController = searchController // Doesn't make sense to add it while no data exists so here is the right place for it
        }
        
        OperationManager.shared.addOperation(fetchOperation)
    }
    
    private func fetchProductList(for category: String) {
        let fetchRequest = RequestOperation(request: ServerAPI.fetchCategoryProductList(category: category), decodeType: [Product].self)
        
        fetchRequest.successHandler = { [weak self] list in
            guard let self else { return }
            
            self.productList = list
            self.updateCollectionData()
        }
        
        OperationManager.shared.addOperation(fetchRequest)
    }
    
    private func updateCollectionData() {
        dataSource?.apply(snapshotForCurrentState(), animatingDifferences: true, completion: nil)
    }
    
    private func reset() {
        productList.removeAll()
        updateCollectionData()
    }
    
    // MARK: - Target Actions
    
    @objc
    private func layoutBarButtonTapped(_ sender: UIBarButtonItem) {
        isGridLayout.toggle()
        sender.image = isGridLayout ? UIImage(systemName: "rectangle.grid.1x2") : UIImage(systemName: "square.grid.2x2")
        
        // Disable it until the animations finishes
        // Cause memory leak in user tap multiple times while animation is going
        sender.isEnabled = false
    }
    
    @objc
    private func filterBarButtonTapped(_ sender: UIBarButtonItem) {
        guard let vc = CategoryListVC.instance as? CategoryListVC else { return }
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - StoryboardBasedView

extension HomeVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}

// MARK: - UISearchResultsUpdating

extension HomeVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count >= 3  {
            inFilterMode = true
            filteredList = productList.filter { $0.title.contains(searchText) }
        } else {
            inFilterMode = false
            filteredList = []
        }
        
        updateCollectionData()
    }
}

// MARK: - CategoryListDelegate

extension HomeVC: CategoryListDelegate {
    func categoryListResetTapped(_ categoryList: CategoryListVC) {
        reset()
        fetchProductList()
        dismiss(animated: true)
    }
    
    func categoryList(_ categoryList: CategoryListVC, userDidPick category: String) {
        reset()
        fetchProductList(for: category)
        dismiss(animated: true)
    }
}
