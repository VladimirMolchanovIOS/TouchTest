//
//  WallPostsViewModel.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WallPostsViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    var _apiRealmModel: APIRealmModel!
    
    // MARK: Reactive Properties
    var wallPosts: Variable<[WallPostModel]> = Variable([])
    var wallPostsCellModels = PublishSubject<[WallPostCellModel]>()
    
    var postSelected = PublishSubject<WallPostCellModel>()
    
    // MARK: Setup
    init(apiRealmModel: APIRealmModel) {
        _apiRealmModel = apiRealmModel
        super.init()
    }
    
    func prepare() {
        loadWallPosts()
        
        _apiRealmModel.wallPosts
            .map( { (postModels) -> [WallPostCellModel] in
                return postModels.map( { (postModel) -> WallPostCellModel in
                    return WallPostCellModel(id: postModel.id, text: postModel.text)
                })
            })
            .subscribe(wallPostsCellModels)
            .addDisposableTo(disposeBag)
        
        _apiRealmModel.wallPosts
            .subscribe(onNext: { [unowned self] (posts) in
                self.wallPosts.value = posts
            })
            .addDisposableTo(disposeBag)
        
        postSelected
            .map { [unowned self] (cellModel) -> WallPostModel in
                return self.wallPosts.value.filter { $0.id == cellModel.id }.first!
            }
            .subscribe(onNext: { [unowned self] in self.showPostDetails(postModel: $0) })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Helpers
    func loadWallPosts() {
        api.getWallPosts(ownerId: Settings.shared.groupId, ownerShortName: nil, count: Settings.shared.numberOfPostsToLoad)
            .subscribe(onNext: { [unowned self] (result) in
                switch result {
                case .failure(let error):
                    let err = error as! ApiError
                    AlertHelper.shared.show(title: "Error \(err.code)", message: err.description)
                case .success(let value):
                    self._apiRealmModel.write(wallPosts: value)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func showPostDetails(postModel: WallPostModel) {
        let pushedVC = PostDetailsViewController(viewModel: PostDetailsViewModel(wallPostModel: postModel))
        GeneralHelper.shared.rootViewController.pushViewController(pushedVC, animated: true)
    }
    
    func updateTextInPost(_ postId: Int, newText: String) {
        _apiRealmModel.updateTextInPost(postId, newText: newText)
    }
    
}
