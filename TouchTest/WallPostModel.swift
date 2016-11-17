//
//  WallPostModel.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class WallPostModel: Object {
    dynamic var id: Int = 0
    dynamic var text: String = ""
    
//    dynamic var postId: Int = 0
//    dynamic var fromId: Int = 0
//    dynamic var ownerId: Int = 0
//    dynamic var date: TimeInterval = 0
//    dynamic var postType: String = ""
    // and others
    
    convenience init(json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.text = json["text"].string ?? ""
    }
    
}
