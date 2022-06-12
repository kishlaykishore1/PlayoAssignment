//
//  HeadLinesVC.swift
//


import UIKit

class HeadLinesVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var refreshControl = UIRefreshControl()
    var arrNewsData = [NewsModelElement]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getNewsList()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSMutableAttributedString(string: "Pull To refresh", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)])
        tableView.addSubview(refreshControl)
        self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: - Helper Methods
    @objc func refresh(sender: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() {
            refreshControl.endRefreshing()
            getNewsList()
        }
    }
    
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            AppDel.window?.rootViewController?.present(alert,animated: true,completion: nil )
        }
    }
}

// MARK: - TableView DataSource Methods
extension HeadLinesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNewsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as! NewsTableCell
        cell.backView.layer.cornerRadius = 12.0
        cell.backView.layer.borderWidth = 1.0
        cell.backView.layer.borderColor = #colorLiteral(red: 0, green: 0.9904155135, blue: 0.9695217013, alpha: 1)
        
        cell.lblHeading.text = arrNewsData[indexPath.row].title
        cell.lblSubHeading.text = arrNewsData[indexPath.row].author
        cell.lblNotificationMessage.text = arrNewsData[indexPath.row].newsModelDescription
        cell.imgNews.downloaded(from: arrNewsData[indexPath.row].urlToImage, contentMode: .scaleAspectFill)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.0
    }
}

// MARK: - Table View Delegate Methods

extension HeadLinesVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.titleString = arrNewsData[indexPath.row].author
        vc.url = arrNewsData[indexPath.row].url
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Receiving News Data Through Api
extension HeadLinesVC: NetworkMangerDelegate {
    
    func getNewsList() {
        if Reachability.isConnectedToNetwork() {
            NetworkManger.shared().delegate = self
            NetworkManger.shared().fetchCurrentNews()
        } else {
            AppDel.showNetworkAlert()
        }
    }
    
    func updateNewsData(response: Data) {
        let responseData = response
        do {
            let responseDic = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary
            let status = responseDic?.object(forKey: "status") as? String ?? ""
            
            if status == "ok"{
                if let dataDict = responseDic?.object(forKey: "articles") as? [[String : Any]] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
                        let decoder = JSONDecoder()
                        let parsedData = try decoder.decode([NewsModelElement].self, from: jsonData)
                        self.arrNewsData = parsedData
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch let err {
                        self.showAlert(err.localizedDescription)
                        print("Err", err)
                    }
                } else {
                    self.showAlert("Key Not Found")
                }
                
            } else {
                self.showAlert("Status Not True")
            }
        } catch let err as NSError {
            print(err)
            self.showAlert(err.localizedDescription)
        }
    }
    
    
}

// MARK: - TableView Cell Class
class NewsTableCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblNotificationMessage: UILabel!
    
    override func awakeFromNib() {
        DispatchQueue.main.async { [self] in
            imgNews.layer.cornerRadius = 12
        }
    }
    
}


