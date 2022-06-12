import Foundation
import UIKit

protocol NetworkMangerDelegate: AnyObject {
    func updateNewsData(response: Data)
}

class NetworkManger {
    
    private static let sharedInstance: NetworkManger = {
        let instance = NetworkManger()
        return instance
    }()
    
    class func shared() -> NetworkManger {
        return sharedInstance
    }
    
    weak var delegate: NetworkMangerDelegate?
    
    public let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height:50))
        aiv.hidesWhenStopped = true
        aiv.backgroundColor = .gray
        aiv.color = .black
        aiv.style = UIActivityIndicatorView.Style.large
        aiv.center = AppDel.window?.center ?? CGPoint(x: 0, y: 50)
        return aiv
    }()
    
    // Generic method
    func fetchCurrentNews() {
        let urlString = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=\(apiKey)"
        performRequest(withURL: urlString)
    }
    
    
    fileprivate func performRequest(withURL urlString: String) {
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.center = AppDel.window?.center ?? CGPoint(x: 0, y: 50)
        activityIndicatorView.startAnimating()
        AppDel.window?.addSubview(activityIndicatorView)
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                guard error == nil else {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeFromSuperview()
                    return
                }
                let status = httpResponse.statusCode
                if status == 200 {
                    if let data = data {
                        self.delegate?.updateNewsData(response: data)
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.removeFromSuperview()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.removeFromSuperview()
                        let alert = UIAlertController(title: "Error", message: "You Have Some Issues With  Api.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        AppDel.window?.rootViewController?.present(alert,animated: true,completion: nil )
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK: - Extension to download Image from URL
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
