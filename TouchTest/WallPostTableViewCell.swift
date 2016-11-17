//
//  WallPostTableViewCell.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import UIKit
import Foundation
import EasyPeasy
import Then

class WallPostTableViewCell: UITableViewCell {
    // MARK: Views
    private var _postTextView: UITextView!
    
    // MARK: Public properties
    var cellModel: WallPostCellModel! {
        didSet {
            if let textAttrStr = try? NSMutableAttributedString(
                data: cellModel.text.data(using: String.Encoding.unicode)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil) {
                let range = NSMakeRange(0, textAttrStr.length)
                textAttrStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: range)
                _postTextView.attributedText = textAttrStr
            } else {
                _postTextView.text = cellModel.text
                _postTextView.font = UIFont.systemFont(ofSize: 14)
            }
        }
    }
    
    // MARK: Setup
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareViews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        layoutViews()
    }
    
    func prepareViews() {
        _postTextView = UITextView().then {
            $0.isEditable = false
            $0.isUserInteractionEnabled = false
            $0.isScrollEnabled = false
            $0.textContainer.lineFragmentPadding = 0
            $0.textContainerInset = EdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            
        }
        contentView.addSubview(_postTextView)
    }
    
    func layoutViews() {
        _postTextView <- [
            Edges(8)
        ]
        
        contentView.layoutIfNeeded()
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
