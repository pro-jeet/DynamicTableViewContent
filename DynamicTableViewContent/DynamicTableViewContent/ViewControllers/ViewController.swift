//
//  ViewController.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import UIKit
import Alamofire

typealias CompletionHandler = (_ success:Bool, _ rows: [Row]?) -> Void

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    lazy var arrInfoModel: Array<Row> = {
        return []
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadAndRefreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView .register(UINib.init(nibName: "InfoModelTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoModelTableViewCell")
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view, typically from a nib.
        self.loadAndRefreshData()
        
    }

    @objc func loadAndRefreshData() {
        
        self.getMostViewedData {[weak self] (isSuccess, arr) in
            if isSuccess{
                guard let weakSelf = self else{
                    return
                }
                guard let arr = arr else{
                    return
                }
                weakSelf.arrInfoModel = arr
                
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func displaAlert(message: String, title: String)
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        
        if self.checkIfAlertViewHasPresented() != nil {
            
        } else {
            topVC?.present(alertView, animated: true, completion: nil)
        }
    }
    
    func checkIfAlertViewHasPresented() -> UIAlertController? {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if topController is UIAlertController {
                return (topController as! UIAlertController)
            } else {
                return nil
            }
        }
        return nil
    }
    
    func getMostViewedData(completionHandler: @escaping CompletionHandler) {

        // write code for internet connection
        if (NetworkReachabilityManager()?.isReachable == false) {
            self.displaAlert(message:"ERROR !", title:  "⚠️ No Internet Connection")
            return
        } else {
            
            Alamofire.request("https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json", method: .get, parameters: nil, encoding: URLEncoding.queryString).validate().responseJSON(queue: DispatchQueue.global(), options:
                .allowFragments, completionHandler: { response in
                
                if let jsonData = response.data {
                    
                    let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
                    let data = jsonString!.data(using: String.Encoding.utf8)
                    let infoModel = try? JSONDecoder().decode(InfoModel.self, from: data!)
                    if let rows = infoModel?.rows {
                        completionHandler(true,rows)
                    }
                    
                    if let title = infoModel?.title {
                        self.title = title
                    }
                    
                    }
                })
            }
        }
 
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell:InfoModelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "InfoModelTableViewCell") as! InfoModelTableViewCell
        cell.imageViewa.image = nil
        cell.title.text = nil
        cell.subTitle.text = nil
        cell.row = self.arrInfoModel[indexPath.row]
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        cell.setNeedsLayout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrInfoModel.count
    }
    
}

