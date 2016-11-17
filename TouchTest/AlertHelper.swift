//
//  AlertHelper.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 17/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit

class AlertHelper {
    static let shared = AlertHelper()
    
    private var _topController: UIViewController {
        return GeneralHelper.shared.topViewController
    }
    
    func show(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        _topController.present(alertController, animated: true, completion: nil)
    }
}
