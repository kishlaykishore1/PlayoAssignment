
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Proparites
    public var url = ""
    var titleString = ""
    var refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        title = titleString
        
        refreshControl.bounds = CGRect(x: 0, y: 50, width: refreshControl.bounds.size.width, height: refreshControl.bounds.size.height)
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSMutableAttributedString(string: "Pull To refresh", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)])
        webView.scrollView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NetworkManger.shared().activityIndicatorView.stopAnimating()
        AppDel.window?.removeFromSuperview()
    }
    
    // MARK: - Helper Methods
    @objc func refresh(sender: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() {
            refreshControl.endRefreshing()
            let request = URLRequest(url: URL(string: url)!)
            webView.load(request)
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.scrollView.showsVerticalScrollIndicator = false
        }
    }
}

// MARK: - UIWebViewDelegate
extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        NetworkManger.shared().activityIndicatorView.startAnimating()
        AppDel.window?.addSubview(NetworkManger.shared().activityIndicatorView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NetworkManger.shared().activityIndicatorView.stopAnimating()
        AppDel.window?.removeFromSuperview()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NetworkManger.shared().activityIndicatorView.stopAnimating()
        AppDel.window?.removeFromSuperview()
        print(error)
    }
}
