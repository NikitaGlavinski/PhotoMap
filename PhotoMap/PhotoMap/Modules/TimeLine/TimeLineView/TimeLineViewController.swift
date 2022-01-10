//
//  TimeLineViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineViewInput: AnyObject {
    func showError(error: Error)
    func setupSectionList(sections: [TimeLineSection])
}

class TimeLineViewController: UIViewController {
    
    var viewModel: TimeLineViewModelProtocol!
    private var filteredSections = [TimeLineSection]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGestures()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func showCategories(_ sender: Any) {
        viewModel.showCategories()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension TimeLineViewController: TimeLineViewInput {
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setupSectionList(sections: [TimeLineSection]) {
        guard let tableView = self.tableView else { return }
        filteredSections = sections
        tableView.reloadData()
    }
}

extension TimeLineViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = filteredSections[indexPath.section].rows[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? TimeLineCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCell(with: rowModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .light)
        label.textColor = .lightGray
        label.text = filteredSections[section].title
        label.frame = CGRect(x: 20, y: -5, width: 200, height: 40)
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
}

extension TimeLineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowModel = filteredSections[indexPath.section].rows[indexPath.row]
        viewModel.showImage(cellModel: rowModel)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimeLineViewController: TimeLineCellDelegate {
    
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) {
        viewModel.loadImage(url: url, completion: completion)
    }
}

extension TimeLineViewController: CustomSearchBarDelegate {
    
    func searchTextDidChange(searchBar: CustomSearchBar, text: String) {
        viewModel.showSearchItems(by: text)
        tableView.reloadData()
    }
}
