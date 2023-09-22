//
//  CategoryListVC.swift
//  eCommerceApp
//
//  Created by Mark Thabit on 22/09/2023.
//

import UIKit

protocol CategoryListDelegate: AnyObject {
    func categoryListResetTapped(_ categoryList: CategoryListVC)
    func categoryList(_ categoryList: CategoryListVC, userDidPick category: String)
}

class CategoryListVC: UIViewController, Instantiatable {
    
    // MARK: - IBOutlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - iVars
    
    weak var delegate: CategoryListDelegate!
    private var categoryList: [String] = [] { didSet { tableView.reloadData() } }
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchCategoryList()
    }
    
    // MARK: - Helper Methods
    
    private func setupUI() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchCategoryList() {
        let fetchRequest = RequestOperation(request: ServerAPI.fetchCategoryList, decodeType: [String].self)
        fetchRequest.successHandler = { [weak self] list in
            guard let self else { return }
            
            self.categoryList = list
        }
        
        OperationManager.shared.addOperation(fetchRequest)
    }
    
    // MARK: - Target Actions
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        delegate.categoryListResetTapped(self)
    }
}

// MARK: - StoryboardBasedView

extension CategoryListVC: StoryboardBasedView {
    static var storyboard: UIStoryboard { .main }
}

// MARK: - UITableViewDataSource

extension CategoryListVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { categoryList.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = categoryList[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.categoryList(self, userDidPick: categoryList[indexPath.row])
    }
}
