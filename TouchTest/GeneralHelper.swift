//
//  GeneralHelper.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 17/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit

class GeneralHelper {
    static let shared = GeneralHelper()
    
    var rootViewController: UINavigationController {
        return UIApplication.shared.delegate!.window!!.rootViewController as! UINavigationController
    }
    
    var topViewController: UIViewController {
        var vc = rootViewController.topViewController!
        while vc.presentedViewController != nil {
            vc = vc.presentedViewController!
        }
        return vc
    }
}
