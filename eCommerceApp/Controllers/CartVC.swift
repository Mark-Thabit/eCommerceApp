//
//  CartVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 21/09/2023.
//

import UIKit

class CartVC: UIViewController, Instantiatable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - iVars
    
    private var cartItemList: [CartItem] { Cart.current.itemList }
    private var productList: [(product: Product, qty: Int)] = []
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.hidesWhenStopped = true
        loadingView.startAnimating()
        loadingView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 44.0)
        return loadingView
    }()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadProductList()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        additionalSafeAreaInsets.top = 20
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "My Cart"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: CartCell.self)
    }
    
    private func loadProductList() {
        guard !cartItemList.isEmpty else { return }
        
        productList.removeAll()
        tableView.reloadData()
        tableView.tableFooterView = loadingView // Show loading to indicate that something is going on
        
        let operationList = cartItemList.map { item in
            let fetchRequest = RequestOperation(request: ServerAPI.fetchProduct(id: Int(item.productId)), decodeType: Product.self)
            fetchRequest.successHandler = { product in
                DispatchQueue.main.async {
                    self.productList.append((product, Int(item.qty)))
                }
            }
            
            return fetchRequest
        }
        
        OperationManager.shared.addOperations(operationList, waitUntilFinished: false)
        OperationManager.shared.addBarrierBlock {
            DispatchQueue.main.async {
                self.loadingView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    private func calculateTotalPrice() {
        _ = productList.reduce(into: 0.0) { result, item in
            result += item.product.price * Double(item.qty)
        }
    }
}

// MARK: - StoryboardBasedView

extension CartVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}

// MARK: - UITableViewDataSource

extension CartVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { productList.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CartCell.self)
        cell.delegate = self
        cell.cartItem = productList[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CartVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = ProductDetailsVC.instance as? ProductDetailsVC else { return }
        vc.product = productList[indexPath.row].product
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CartCellDelegate

extension CartVC: CartCellDelegate {
    func cartCellDeleteTapped(_ cartCell: CartCell) {
        guard 
            let indexPath = tableView.indexPath(for: cartCell),
            Cart.current.removeItem(with: productList[indexPath.row].product.id) // Make sure we removed it from coreData context first
        else { return }
        
        tableView.beginUpdates()
        productList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func cartCell(_ cartCell: CartCell, userUpdateQuantity count: Int) {
        guard let indexPath = tableView.indexPath(for: cartCell) else { return }
        
        cartItemList.first { $0.productId == productList[indexPath.row].product.id }?.qty = Int16(count) // Update managedObject qty value
        // Update price
    }
}
