//
//  NetworkManager.swift
//  GitHubUsers
//
//  Created by Jeff on 18/07/2021.
//

import UIKit

struct NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    
    func makeRequest(toUrl url: String,
                     withActivityIndicator activityIndicator: Bool = false,
              completion: @escaping (_ completed: Result<Data, NetworkError>) -> ()){
        
        if activityIndicator { Helper.showLoader() }
        
        guard let url: URL = URL(string: url) else {
            Helper.debugLogs(anyData: "Could not create URL", andTitle: "Error")
            return
        }
        
        autoreleasepool {
            SESSION.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    if let urlError = error as? URLError,
                       urlError.code == .timedOut {
                        completion(.failure(.timeout("API request timeout")))
                    }
                    completion(.failure(.faliure(error!)))
                    if activityIndicator { Helper.removeLoader() }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    if let httpResponse = response as? HTTPURLResponse {
                        completion(.failure(.badCode(httpResponse.statusCode)))
                        if activityIndicator { Helper.removeLoader() }
                    } else {
                        completion(.failure(.invalid("Invalid response from the API")))
                        if activityIndicator { Helper.removeLoader() }
                    }
                    return
                }
                
                guard let data = data else {
                    Helper.debugLogs(anyData: "Data not recieved", andTitle: "Error")
                    completion(.failure(.invalid("Data not recieved")))
                    if activityIndicator { Helper.removeLoader() }
                    return
                }
                completion(.success(data))
                if activityIndicator { Helper.removeLoader() }
            }.resume()
        }
    }
    
    func downloadAndCacheImage(fromURL url: URL, toFile file: URL, completion: @escaping (Error?) -> ()){
        SESSION.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL else {
                completion(error)
                return
            }
            
            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                
                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )
                
                completion(nil)
            }
            
            // Handle potential file system errors
            catch _ {
                completion(error)
            }
            
        }.resume()
    }
    
    func loadData(
        url: URL,
        withIndicatorOnImageView imageView: UIImageView?,
        completion: @escaping (Data? ,URL ,Error?) -> Void
    ) {
            
        let activityIndicator = UIActivityIndicatorView()
        
        if let imageView = imageView {
            activityIndicator.color = UIColor.AppTheme.red
            
            imageView.addSubview(activityIndicator)
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
            imageView.image = nil
        }
        
        activityIndicator.startAnimating()
        
        // Compute a path to the URL in the cache
        let cachedFile = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                url.lastPathComponent,
                isDirectory: false
            )
        
        // If the image exists in the cache,
        // load the image from the cache and exit
        do {
            let data = try Data(contentsOf: cachedFile)
            MAIN_QUEUE.async {
                activityIndicator.stopAnimating()
            }
            completion(data, url, nil)
        } catch {
            // If the image does not exist in the cache,
            // download the image to the cache
            NetworkManager.shared.downloadAndCacheImage(fromURL: url, toFile: cachedFile) { (error) in
                do {
                    let data = try Data(contentsOf: cachedFile)
                    MAIN_QUEUE.async {
                        activityIndicator.stopAnimating()
                    }
                    completion(data, url, nil)
                } catch {
                    MAIN_QUEUE.async {
                        activityIndicator.stopAnimating()
                    }
                    completion(nil, url, error)
                }
            }
        }
    }

}
