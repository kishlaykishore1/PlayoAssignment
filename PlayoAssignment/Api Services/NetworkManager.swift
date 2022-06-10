import Foundation
import UIKit

protocol NetworkMangerDelegate: AnyObject {
    func updateNewsData(response: Data)
}

class NetworkManger {
    
    weak var delegate: NetworkMangerDelegate?
    var arrNewsData = [NewsModelElement]()
    
    public let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        aiv.hidesWhenStopped = true
        aiv.color = .black
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
                        let alert = UIAlertController(title: "Error", message: "You Have Entered an incorrect city name.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        AppDel.window?.rootViewController?.present(alert,animated: true,completion: nil )
                    }
                }
            }
        }
        task.resume()
    }
    
//    fileprivate func parseJSON(with data: Data) -> NewsModelElement? {
//        let decoder = JSONDecoder()
//        do {
//            let currentNewsData = try decoder.decode([NewsModelElement].self, from: data)
//            guard let currentNews = CurrentWeather(currentWeatherData: currentWeatherData) else {
//                return nil
//            }
//            return currentWeather
//        } catch let error as NSError {
//            print(error)
//        }
//        return nil
//    }
}
