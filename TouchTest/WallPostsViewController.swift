//
//  WallPostsViewController.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyPeasy
import Then

class WallPostsViewController: UIViewController {
    
    // MARK: Constants
    private let kWallPostCellReuseId = "WallPostCellReuseId"
    let disposeBag = DisposeBag()
    
    // MARK: Views
    private var _wallPostsTableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: WallPostsViewModel!

    // MARK: Init
    init(viewModel: WallPostsViewModel) {
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
        _wallPostsTableView = UITableView().then {
            $0.backgroundColor = .white
            $0.register(WallPostTableViewCell.self, forCellReuseIdentifier: kWallPostCellReuseId)
            $0.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            $0.estimatedRowHeight = 200
            $0.rowHeight = UITableViewAutomaticDimension
            $0.tableFooterView = UIView()
        }
        view.addSubview(_wallPostsTableView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray).then {
            $0.startAnimating()
            $0.hidesWhenStopped = true
        }
        view.addSubview(activityIndicator)
    }
    
    func prepareNavigationItem() {
        navigationItem.title = Settings.shared.groupDomain
    }
    
    func layoutViews() {
        _wallPostsTableView <- [
            Edges()
        ]
        
        activityIndicator <- [
            CenterX(), CenterY()
        ]
        
        view.layoutIfNeeded()
    }
    
    func prepareViewModel() {
        
        viewModel.wallPostsCellModels.asObservable()
            .bindTo(_wallPostsTableView.rx.items(cellIdentifier: kWallPostCellReuseId)) { (row, elem: WallPostCellModel, cell: WallPostTableViewCell) in
                cell.cellModel = elem
        }
            .addDisposableTo(disposeBag)
        
        viewModel.prepare()
        
        viewModel.wallPostsCellModels.asObservable()
            .map { _ in () }
            .subscribe(onNext: { [unowned self] in
                self.activityIndicator.stopAnimating()
            })
            .addDisposableTo(disposeBag)
        
        _wallPostsTableView.rx.itemSelected
            .do(onNext: { [unowned self] in self._wallPostsTableView.deselectRow(at: $0, animated: true) })
            .map { (self._wallPostsTableView.cellForRow(at: $0) as! WallPostTableViewCell).cellModel }
            .subscribe(viewModel.postSelected)
            .addDisposableTo(disposeBag)
        
        
    }
}
