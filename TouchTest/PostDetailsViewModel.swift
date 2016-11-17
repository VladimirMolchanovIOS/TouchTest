//
//  PostDetailsViewModel.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import RxSwift

class PostDetailsViewModel: NSObject {
    let disposeBag = DisposeBag()
    
    // MARK: Private properties
    private var _postModel: WallPostModel!
    
    // MARK: Reactive Properties
    var addExclPointAction = PublishSubject<()>()
    var postText: Variable<String?> = Variable("")
    
    // MARK: Setup
    init(wallPostModel: WallPostModel) {
        _postModel = wallPostModel
        super.init()
    }
    
    func prepare() {
        postText.value = _postModel.text
        
        addExclPointAction
            .subscribe(onNext: { [unowned self] in
                self.postText.value = self.postText.value! + "!"
                self.updateTextInPost(self._postModel.id, newText: self.postText.value!)
                
            })
            .addDisposableTo(disposeBag)
            
    }
    
    // MARK: Helpers
    func updateTextInPost(_ postId: Int, newText: String) {
        let wallPostsVC = GeneralHelper.shared.rootViewController.viewControllers.first! as! WallPostsViewController
        wallPostsVC.viewModel.updateTextInPost(postId, newText: newText)
        
    }
}
