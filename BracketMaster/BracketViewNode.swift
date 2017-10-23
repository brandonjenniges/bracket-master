//
//  BracketViewNode.swift
//  BracketMaster
//
//  Created by Brandon Jenniges on 10/20/17.
//  Copyright © 2017 BrandonJenniges. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class BracketViewNode: ASDisplayNode {
    
    let OFFSET_PERCENT: CGFloat = 0.75
    
    lazy var pagerNode: ASCollectionNode = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width * self.OFFSET_PERCENT, height: UIScreen.main.bounds.size.height)
        return ASCollectionNode(collectionViewLayout: layout)        
    }()
    
    override init() {
        super.init()
        self.backgroundColor = .blue
        self.automaticallyManagesSubnodes = true
        self.pagerNode.view.bounces = false
        self.pagerNode.view.showsVerticalScrollIndicator = false
        self.pagerNode.view.showsHorizontalScrollIndicator = false
        self.pagerNode.view.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insetSpec = ASInsetLayoutSpec(insets: .zero, child: self.pagerNode)
        return insetSpec
    }
    
    
}

