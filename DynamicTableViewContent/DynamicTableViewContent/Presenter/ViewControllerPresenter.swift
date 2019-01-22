//
//  ViewControllerPresenter.swift
//  DynamicTableViewContent
//
//  Created by Jitesh Sharma on 15/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct AlertPresenter {
    
    let alertMessage: String?
    // The title of the button to accept the confirmation
    let alertTitle: String?
    // The title of the button to reject the confirmation
    let okTitle = "OK"
    // A closure to be run when the user taps one of the
    // alert's buttons. 

    // Common Method for displaying alert takes message and title as input.
    func displaAlert(in viewController: UIViewController) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { alert in
            NotificationCenter.default.post(name: Notification.Name("refreshControl"), object: nil)
        }))
        
        viewController.present(alert, animated: true)
    }
}

class ViewControllerPresenter {
    
    private var serviceString = String()
    weak private var controller : UIViewController?
    
    init(serviceString: String) {
        self.serviceString = serviceString
    }
    
    func attachedController (controler: UIViewController){
        controller = controler
    }
    
    func detachController() {
        controller = nil
    }
    
    func getDataFromService(completionHandler: @escaping CompletionHandler) {
        
        // Alamofire request for calling service.
        // Called in asyn global queue.
        Alamofire.request(serviceString, method: .get, parameters: nil, encoding: URLEncoding.queryString).validate().responseJSON(queue: DispatchQueue.global(), options:
            .allowFragments, completionHandler: { response in
                
                if let jsonData = response.data {

                    let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
                    let data = jsonString!.data(using: String.Encoding.utf8)
                    let infoModel = try? JSONDecoder().decode(InfoModel.self, from: data!)
                    if var rows = infoModel?.rows {
                        guard let title = infoModel?.title else {
                            completionHandler(false, nil, nil)
                            return
                        }
                        // Removing Row is all three values i.e, title, description and imageHref are empty, so as to prevent showing empty cell.
                        var index:Int = 0
                        for row in rows {
                            let myDesc = row.description
                            let myTitle = row.title
                            let url = row.imageHref
                            if(myDesc == nil && myTitle == nil && url == nil){
                                rows.remove(at: index)
                            }
                            index = index + 1
                        }
                        completionHandler(true,rows, title)
                    }
                }
        })
    }
}
