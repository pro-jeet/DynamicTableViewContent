//
//  ViewController.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

/**
 ## Feature Support
 
 This class works as a Root View Controller for windows. It supports:
 
 - Data rendering provided by ViewControllerPresenter Class.
 - Has Table view to show data
 
 */

typealias CompletionHandler = (_ success:Bool, _ rows: [Row]?, _ title: String?) -> Void

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constants
    
    //Used as Cell Identifier for InfoModelTableViewCell
    let cellIdendifier: String = "InfoModelTableViewCell"
    let notificationIdendifier: String = "reloadCell"
    let serviceUrlForViewController: String = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    let errorTitle: String = "ERROR !"
    let errorMessageForNoInternet: String = "⚠️ No Internet Connection"
    let errorMessageForNoServiceFailure: String = "⚠️ Something Went Wrong!"
    let errorMessageForNoData: String = "⚠️ No Data Available!"
    let notificationUserInfoKeyCell: String = "cell"
    
    private let viewControllerPresenter = ViewControllerPresenter(serviceString: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")
    
    // MARK: - UI Components
    let tableView = UITableView()
    var refreshControl: UIRefreshControl!
    var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - Variables
    
    //Used to store "Row" type data to be loaded on InfoModelTableViewCell
    lazy var infoModelArray: Array<Row> = {
        return []
    }()
    
    // MARK: - UI Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding observer to keep track of image aync call to update that particular cell
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCell(_:)), name: NSNotification.Name(rawValue: notificationIdendifier), object: nil)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(tableView)
        // Setting constraints for tableView
        self.setTableConstraints()
        
        // Setting DataSource and Delegate for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Adding refresh control to call service and reload data in tableView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.loadAndRefreshDataFromService), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.register(InfoModelTableViewCell.self, forCellReuseIdentifier: cellIdendifier)
        self.loadAndRefreshDataFromService()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let activityIndicator = activityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // Method for adding activityIndicator for loading
    func setupActivityIndicator() {
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: view.bounds.size.width/2-25, y: view.bounds.size.height/2-25, width: 50, height: 50))
        activityIndicator.type = . circleStrokeSpin
        activityIndicator.color = .darkGray
        view.addSubview(activityIndicator)
    }
    
    // Method for adding constraints for tableView
    func setTableConstraints() {

         // Adding constraints for tableView
       
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        }
        if #available(iOS 11.0, *) {
            tableView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        } else {
            tableView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        }
        if #available(iOS 11.0, *) {
            tableView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            tableView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        }
        if #available(iOS 11.0, *) {
            tableView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        }
    }
    
    // Method for reloading Cell after image gets downloaded.
    // This method is called from Notification
    
    @objc func reloadCell(_ notification: NSNotification ) {
        
        if let notify = notification.userInfo {
            
            if let currentCell = notify[notificationUserInfoKeyCell] {
                
                guard let indexPath = self.tableView.indexPath(for: (currentCell as? InfoModelTableViewCell)!) else {
                    // Note, this is to make sure, cell to reload is still in visible rect
                    return
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                if let activityIndicator = activityIndicator {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // Method for Calling for service to get data for table view.
    @objc func loadAndRefreshDataFromService() {
        
        if let activityIndicator = activityIndicator {
            activityIndicator.startAnimating()
        } else {
            setupActivityIndicator()
            activityIndicator.startAnimating()
        }
        self.getDataFromService { [weak self] (isSuccess, arr, _) in
            if isSuccess {
                guard let weakSelf = self else{
                    return
                }
                guard let arr = arr else{
                    return
                }
                weakSelf.infoModelArray = arr
                
                // Reloading TableView to update data received from service in table view
                // Using Main thread to update the UI
                
                DispatchQueue.main.async {
                    if let activityIndicator = weakSelf.activityIndicator {
                        activityIndicator.stopAnimating()
                    }
                    weakSelf.tableView.reloadData()
                    weakSelf.refreshControl.endRefreshing()
                    weakSelf.tableView.layoutSubviews()
                    weakSelf.tableView.layoutIfNeeded()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Method for Calling for service to get data.
    func getDataFromService (completionHandler: @escaping CompletionHandler) {
        
        // Checking if internet connection is available.
        if (NetworkReachabilityManager()?.isReachable == false) {
            DispatchQueue.main.async {
                // Displaying Alert if No internet connection.
                self.refreshControl.endRefreshing()
                let presenter = AlertPresenter(
                    alertMessage: self.errorMessageForNoInternet,
                    alertTitle: self.errorTitle
                )
                presenter.displaAlert(in: self)
                 return
            }
        } else {
            viewControllerPresenter.attachedController(controler: self)
            viewControllerPresenter.getDataFromService(completionHandler: {[weak self] (status, rows, title) in
                if let weekSelf = self {
                    weekSelf.viewControllerPresenter.detachController()
                    if status {
                        if (rows?.count)! > 0 {
                            // Using Main thread to update the UI
                            DispatchQueue.main.async {
                                weekSelf.title = title
                            }
                            // The happy scenarios if Data is Available.
                            completionHandler(status, rows, title)
                            
                        } else {
                            // Displaying Alert if No Data Available.
                            DispatchQueue.main.async {
                                weekSelf.refreshControl.endRefreshing()
                                let presenter = AlertPresenter(
                                    alertMessage: weekSelf.errorMessageForNoData,
                                    alertTitle: weekSelf.errorTitle
                                )
                                presenter.displaAlert(in: weekSelf)
                                return
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            // Displaying Alert if service calls fails Available.
                            weekSelf.refreshControl.endRefreshing()
                            let presenter = AlertPresenter(
                                alertMessage: weekSelf.errorMessageForNoServiceFailure,
                                alertTitle: weekSelf.errorTitle
                            )
                            presenter.displaAlert(in: weekSelf)
                            return
                        }
                    }
                }
            })
        }
    }
    
}

// Extension for UITableViewDelegate, UITableViewDataSource
extension ViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdendifier, for: indexPath) as! InfoModelTableViewCell
        cell.cellImageView.image = nil
        cell.titleLabel.text = nil
        cell.descriptionLabel.text = nil
        cell.row = self.infoModelArray[indexPath.row]
        cell.layoutSubviews()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoModelArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
