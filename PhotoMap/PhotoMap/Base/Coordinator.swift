//
//  Coordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
    func add(childCoordinator: Coordinator)
    func remove(childCoordinator: Coordinator)
}
