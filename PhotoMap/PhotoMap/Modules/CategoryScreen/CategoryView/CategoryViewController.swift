//
//  CategoryViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import UIKit

protocol CategoryViewInput: AnyObject {
    func setCategories(categories: [CategoryModel])
}

class CategoryViewController: UIViewController {
    
    var viewModel: CategoryViewModelProtocol!
    private var cellModels = [CategoryModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        viewModel.saveCategories(categories: cellModels)
    }
}

extension CategoryViewController: CategoryViewInput {
    
    func setCategories(categories: [CategoryModel]) {
        cellModels = categories
        tableView.reloadData()
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: cellModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellModels[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
