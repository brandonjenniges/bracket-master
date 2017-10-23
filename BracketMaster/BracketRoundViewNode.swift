//
//  BracketRoundViewNode.swift
//  BracketMaster
//
//  Created by Brandon Jenniges on 10/20/17.
//  Copyright © 2017 BrandonJenniges. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class BracketRoundViewNode: ASDisplayNode {
    
    static let defaultSpacing: CGFloat = 30
    
    lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = BracketRoundViewNode.defaultSpacing
        return layout
    }()
    
    lazy var spacedLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = BracketRoundMatchNode.height + BracketRoundViewNode.defaultSpacing * 2
        return layout
    }()
    
    lazy var collectionNode: ASCollectionNode = {
        return ASCollectionNode(collectionViewLayout: self.collectionLayout)
    }()
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.showsHorizontalScrollIndicator = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insetSpec = ASInsetLayoutSpec(insets: .zero, child: collectionNode)
        return insetSpec
    }
    
    
}
