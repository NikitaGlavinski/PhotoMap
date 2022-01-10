//
//  TimeLineViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineViewModelProtocol: AnyObject {
    func viewDidLoad()
    func loadImage(url: String, completion: @escaping (UIImage) -> ())
    func showImage(cellModel: TimeLineCellModel)
    func showCategories()
    func showSearchItems(by text: String)
}

class TimeLineViewModel {
    weak var view: TimeLineViewInput!
    var coordinator: TimeLineCoordinatorDelegate!
    
    private var photoRestModels = [PhotoRestModel]()
    
    private var sections = [TimeLineSection]()
    private var filteredSections = [TimeLineSection]()
    private var selectedCategories: [Category] = [.friends, .nature, .standart]
    
    init() {
        FirebaseService.shared.updateSignal = { [weak self] in
            self?.viewDidLoad()
        }
    }
    
    private func filterSelectedCategories() {
        filteredSections = sections.compactMap({ section in
            var filteredRows = [TimeLineCellModel]()
            for row in section.rows {
                let category = Category.init(rawValue: row.category) ?? .friends
                if selectedCategories.contains(category) {
                    filteredRows.append(row)
                }
            }
            return TimeLineSection(title: section.title, rows: filteredRows)
        })
    }
    
    private func filterSectionsWith(text: String) {
        if text == "" {
            filterSelectedCategories()
        } else {
            filteredSections = sections.compactMap({ section in
                var filteredRows = [TimeLineCellModel]()
                for cell in section.rows {
                    let category = Category.init(rawValue: cell.category) ?? .friends
                    let selectCategoryValue = selectedCategories.count > 0 ? selectedCategories.contains(category) : false
                    if cell.infoLabelText.contains("#\(text)") && selectCategoryValue {
                        filteredRows.append(cell)
                    }
                }
                return TimeLineSection(title: section.title, rows: filteredRows)
            })
        }
    }
    
    deinit {
        FirebaseService.shared.updateSignal = nil
    }
}

extension TimeLineViewModel: TimeLineViewModelProtocol {
    
    func viewDidLoad() {
        let restModels = SecureStorageService.shared.obtainPhotoModels()
        self.photoRestModels = restModels
        let cellModels = restModels.compactMap({TimeLineCellModel(photoRestModel: $0)})
            .sorted(by: {$0.date > $1.date})
        var sections = [TimeLineSection]()
        for cell in cellModels {
            guard let index = sections.firstIndex(where: {$0.title == cell.sectionTitle}) else {
                sections.append(TimeLineSection(title: cell.sectionTitle, rows: [cell]))
                continue
            }
            sections[index].rows.append(cell)
        }
        self.sections = sections
        self.filterSelectedCategories()
        DispatchQueue.main.async {
            self.view.setupSectionList(sections: self.filteredSections)
        }
    }
    
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) {
        NetworkService.shared.loadImageFrom(url: url, completion: completion) { error in
            self.view.showError(error: error)
        }
    }
    
    func showImage(cellModel: TimeLineCellModel) {
        guard let index = photoRestModels.firstIndex(where: {$0.id == cellModel.id}) else { return }
        let photoCardModel = PhotoCardModel(restModel: photoRestModels[index])
        coordinator.showImage(model: photoCardModel)
    }
    
    func showCategories() {
        var categories = [
            CategoryModel(title: "FRIENDS", isSelected: false),
            CategoryModel(title: "NATURE", isSelected: false),
            CategoryModel(title: "DEFAULT", isSelected: false)
        ]
        for category in selectedCategories {
            guard let index = categories.firstIndex(where: {$0.title == category.rawValue}) else { return }
            categories[index].isSelected = true
        }
        coordinator.showCategories(categories: categories, delegate: self)
    }
    
    func showSearchItems(by text: String) {
        filterSectionsWith(text: text)
        view.setupSectionList(sections: filteredSections)
    }
}

extension TimeLineViewModel: CategorySelectionDelegate {
    func updateSelectedCategories(categories: [CategoryModel]) {
        var selectedCategories = [Category]()
        for category in categories {
            if category.isSelected {
                guard let selectedCategory = Category.init(rawValue: category.title) else { return }
                selectedCategories.append(selectedCategory)
            }
        }
        self.selectedCategories = selectedCategories
        self.filterSelectedCategories()
        view.setupSectionList(sections: filteredSections)
    }
}
