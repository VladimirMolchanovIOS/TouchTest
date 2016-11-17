//
//  PostDetailsViewController.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import EasyPeasy

class PostDetailsViewController: UIViewController {
    
    // MARK: Constants
    let disposeBag = DisposeBag()
    
    // MARK: Views
    private var _postTextView: UITextView!
    private var plusButton: UIBarButtonItem!
    
    var viewModel: PostDetailsViewModel!
    
    // MARK: Init
    init(viewModel: PostDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        prepareNavigationItem()
        prepareViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutViews()
    }
    
    // MARK: Setup
    func prepareViews() {
        _postTextView = UITextView().then {
            $0.isEditable = false
            $0.dataDetectorTypes = [.link]
            $0.textContainer.lineFragmentPadding = 0
            $0.textContainerInset = EdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
        view.addSubview(_postTextView)
    }
    
    func prepareNavigationItem() {
        navigationItem.title = "Запись"
        plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = plusButton
    }
    
    func layoutViews() {
        _postTextView <- [
            Edges()
        ]
        
        view.layoutIfNeeded()
    }
    
    func prepareViewModel() {
        
        viewModel.postText.asObservable()
            .subscribe(onNext: { [unowned self] (postText) in
                if let textAttrStr = try? NSMutableAttributedString(
                    data: postText!.data(using: String.Encoding.unicode)!,
                    options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil) {
                    let range = NSMakeRange(0, textAttrStr.length)
                    textAttrStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: range)
                    self._postTextView.attributedText = textAttrStr
                } else {
                    self._postTextView.text = postText
                    self._postTextView.font = UIFont.systemFont(ofSize: 16)
                }
            })
            .addDisposableTo(disposeBag)
    
         viewModel.prepare()
        
        plusButton.rx.tap
            .subscribe(viewModel.addExclPointAction)
            .addDisposableTo(disposeBag)
        
        
    }

}
