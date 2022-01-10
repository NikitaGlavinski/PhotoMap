//
//  NetworkService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import Foundation
import UIKit
import Alamofire

protocol NetworkServiceProtocol {
    func loadImageFrom(url: String, completion: @escaping (UIImage) -> (), failure: @escaping (Error) -> ())
}

class NetworkService: NetworkServiceProtocol {
    
    static let shared: NetworkServiceProtocol = NetworkService()
    private init() {}
    
    func loadImageFrom(url: String, completion: @escaping (UIImage) -> (), failure: @escaping (Error) -> ()) {
        var baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoName = url.components(separatedBy: "/").last ?? UUID().uuidString
        baseUrl.appendPathComponent("photos")
        do {
            try FileManager.default.createDirectory(at: baseUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            failure(error)
        }
        baseUrl.appendPathComponent(photoName)
        if FileManager.default.fileExists(atPath: baseUrl.path) {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: baseUrl.path)),
                let image = UIImage(data: data)
            else { return }
            completion(image)
            return
        }
        let destination: DownloadRequest.Destination = { _, _ in
            return (baseUrl, [.removePreviousFile])
        }
        
        AF.download(URL(string: url)!, to: destination).responseData { response in
            guard
                let destinationUrl = response.fileURL,
                let data = try? Data(contentsOf: URL(fileURLWithPath: destinationUrl.path)),
                let image = UIImage(data: data)
            else {
                failure(NetworkError.noData)
                return
            }
           
            completion(image)
        }
    }
}
