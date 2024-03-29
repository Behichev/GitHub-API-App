//
//  CacheManager.swift
//  GitHub API App
//
//  Created by Ivan Behichev on 18.01.2023.
//

import UIKit

final class CacheManager {
    
    private typealias ImageCache = NSCache<NSString, UIImage>
    private var imageCache = ImageCache()
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil,
                      let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                       let self = self else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            dataTask.resume()
        }
    }
}
