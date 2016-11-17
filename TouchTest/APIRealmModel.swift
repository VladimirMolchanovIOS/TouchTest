//
//  APIRealmModel.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 17/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import RxSwift
//import RxCocoa
import RealmSwift
import RxRealm
import Alamofire


class APIRealmModel {
    // MARK: Constants
    let disposeBag = DisposeBag()
    let realm = try! Realm()
    
    // MARK: Reactive Properties
    private var _wallPostsSubject = PublishSubject<[WallPostModel]>()

    var wallPosts: Observable<[WallPostModel]> {
        return _wallPostsSubject.shareReplay(1)
    }

    // MARK: Setup
    init() {
       Observable.from(realm.objects(WallPostModel.self))
        .map { $0.toArray() }
        .subscribe(_wallPostsSubject)
        .addDisposableTo(disposeBag)
        
        
    }
    
    // MARK: Helpers
    func write(wallPosts: [WallPostModel]) {
        try! realm.write {
            realm.delete(realm.objects(WallPostModel.self))
            wallPosts.forEach { realm.add($0) }
        }
    }
    
    func updateTextInPost(_ postId: Int, newText: String) {
        let postToUpdate = realm.objects(WallPostModel.self).filter { $0.id == postId }.first!
        try! realm.write {
            postToUpdate.text = newText
        }
    }
}
